import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_bottom.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/edit_node_modal.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_core.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/popups/teacher/confirm_popup.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/generated_node.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

// UI State class สำหรับจัดการ node ใน UI
class NodeUiState {
  String title;
  String description;
  int sequence;
  String? realNodeId;
  bool isCreated;

  NodeUiState({
    required this.title,
    required this.description,
    required this.sequence,
    this.realNodeId,
    this.isCreated = false,
  });
}

class TeacherNodesOverviewPage extends StatefulWidget {
  final String title;
  final List<GeneratedNode>? aiNodes;
  final String pathId;

  /// True เมื่อ path ถูกสร้างขึ้นมาใหม่ในรอบ session นี้ (มาจาก
  /// CreateLearningPathInputPage หรือ AINodeReviewPage). ใช้สำหรับการ cleanup
  /// path อัตโนมัติเมื่อผู้ใช้กดย้อนกลับโดยไม่ได้กด Save Draft / Publish เพื่อ
  /// ป้องกัน orphan paths ค้างใน backend
  final bool isNewlyCreated;

  const TeacherNodesOverviewPage({
    super.key,
    required this.title,
    this.aiNodes,
    required this.pathId,
    this.isNewlyCreated = false,
  });

  @override
  State<TeacherNodesOverviewPage> createState() =>
      _TeacherNodesOverviewPageState();
}

class _TeacherNodesOverviewPageState extends State<TeacherNodesOverviewPage> {
  late List<NodeUiState> _uiNodes;
  int? _pendingNodeIndex; // เก็บ index ของ node ที่กำลังสร้างอยู่
  final List<int> _createQueue =
      []; // คิว sequence ของ nodes ที่รอสร้างตามลำดับ
  Timer? _draftAutoSaveTimer;
  String? _userId;
  List<NodeDetail>? _cachedNodes; // Cache nodes from backend
  LearningPath? _cachedLearningPath; // Cache learning path details for updating
  bool _pendingPublish = false; // รอ node สร้างเสร็จแล้วค่อย publish
  bool _pendingSaveDraft = false; // รอ node สร้างเสร็จแล้วค่อย save draft
  bool _queuedSaveDraftAfterPathLoad = false;
  Timer? _queuedSaveDraftRetryTimer;
  int _queuedSaveDraftRetryCount = 0;
  bool _queuedPublishAfterPathLoad = false;
  Timer? _queuedPublishRetryTimer;
  int _queuedPublishRetryCount = 0;
  bool _shouldExitAfterPathUpdate = false;
  String? _requestedPathUpdateStatus;
  bool _allowPopAfterSave = false;
  late String
  _displayTitle; // Title ที่แสดงใน header (อัพเดทจาก backend เมื่อโหลดเสร็จ)

  bool get _isPublished =>
      _cachedLearningPath?.publishStatus.toLowerCase() == 'published';

  bool get _isAiPath => widget.aiNodes != null && widget.aiNodes!.isNotEmpty;

  @override
  void dispose() {
    _draftAutoSaveTimer?.cancel();
    _queuedSaveDraftRetryTimer?.cancel();
    _queuedPublishRetryTimer?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPopAutoSaveDraft() async {
    // Auto-save draft on back navigation has been disabled.
    // The user must explicitly press the "Save Draft" button to save changes.
    return true;
  }

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.title;
    _loadUserAndFetchNodes();

    // ถ้ามี AI nodes ให้ใช้ ถ้าไม่มีให้สร้าง default node เปล่าๆ
    if (widget.aiNodes != null && widget.aiNodes!.isNotEmpty) {
      // Keep sequence unique and stable in UI order to avoid draft-node loss
      // when AI-generated sequence values are duplicated.
      _uiNodes = widget.aiNodes!.asMap().entries.map((entry) {
        final index = entry.key;
        final aiNode = entry.value;
        return NodeUiState(
          title: aiNode.title,
          description: "",
          sequence: index + 1,
          isCreated: false,
        );
      }).toList();
    } else {
      // Create Plain Path: สร้าง node เปล่าๆ 1 node (ถ้ายังไม่มี nodes จาก backend)
      _uiNodes = [
        NodeUiState(
          title: 'New Node',
          description: '',
          sequence: 1,
          isCreated: false,
        ),
      ];
    }
  }

  Future<void> _loadUserAndFetchNodes() async {
    final storedUserId = await getIt<IAuthRepository>().getUserId();
    if (!mounted) return;

    setState(() => _userId = storedUserId ?? '');
    _fetchNodes(storedUserId ?? '');
    _fetchLearningPathDetail();
  }

  void _fetchNodes(String userId) {
    if (userId.isEmpty) return;
    // Fetch existing nodes from backend
    context.read<LearningPathBloc>().add(
      FetchNodesForPath(pathId: widget.pathId),
    );
  }

  void _fetchLearningPathDetail() {
    // Fetch learning path details for updating publish status
    LogHandler.info(
      'TeacherNodesOverview: Fetch learning path detail requested (pathId=${widget.pathId})',
    );
    context.read<LearningPathBloc>().add(
      GetLearningPathByIdEvent(pathId: widget.pathId),
    );
  }

  void _startQueuedSaveDraftRetryWatchdog() {
    _queuedSaveDraftRetryTimer?.cancel();
    _queuedSaveDraftRetryCount = 0;

    _queuedSaveDraftRetryTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (!_queuedSaveDraftAfterPathLoad || _cachedLearningPath != null) {
        timer.cancel();
        return;
      }

      _queuedSaveDraftRetryCount++;
      if (_queuedSaveDraftRetryCount > 8) {
        timer.cancel();
        _queuedSaveDraftAfterPathLoad = false;
        LogHandler.error(
          'TeacherNodesOverview: Save Draft queue timeout - learning path detail did not load',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to load learning path data for Save Draft. Please try again.',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.cancel,
          ),
        );
        return;
      }

      LogHandler.warning(
        'TeacherNodesOverview: Retrying detail fetch for queued Save Draft (${_queuedSaveDraftRetryCount}/8)',
      );
      _fetchLearningPathDetail();
    });
  }

  void _startQueuedPublishRetryWatchdog() {
    _queuedPublishRetryTimer?.cancel();
    _queuedPublishRetryCount = 0;

    _queuedPublishRetryTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (!_queuedPublishAfterPathLoad || _cachedLearningPath != null) {
        timer.cancel();
        return;
      }

      _queuedPublishRetryCount++;
      if (_queuedPublishRetryCount > 8) {
        timer.cancel();
        _queuedPublishAfterPathLoad = false;
        LogHandler.error(
          'TeacherNodesOverview: Publish queue timeout - learning path detail did not load',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to load learning path data for Publish. Please try again.',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.cancel,
          ),
        );
        return;
      }

      LogHandler.warning(
        'TeacherNodesOverview: Retrying detail fetch for queued Publish (${_queuedPublishRetryCount}/8)',
      );
      _fetchLearningPathDetail();
    });
  }

  void _handleCreateNode(int sequence) {
    final index = _uiNodes.indexWhere(
      (n) => n.sequence == sequence && !n.isCreated,
    );
    if (index < 0) {
      // Node might already be created from a concurrent refresh; continue queue.
      if (_createQueue.isNotEmpty) {
        _handleCreateNode(_createQueue.removeAt(0));
      }
      return;
    }

    final node = _uiNodes[index];

    setState(() {
      _pendingNodeIndex = index;
    });

    context.read<LearningPathBloc>().add(
      CreateNodeEvent(
        title: node.title,
        description: node.description,
        pathId: widget.pathId,
        sequence: node.sequence.toString(),
        linkvdo: '',
        materials: null, // Materials จะถูกเพิ่มผ่าน EditNodeModal
      ),
    );
  }

  /// สร้าง nodes ทีละตัวตามลำดับ (sequential) เพื่อหลีกเลี่ยง droppable transformer
  /// ที่จะ drop events ที่ส่งพร้อมกัน
  void _startSequentialCreate(List<int> sequences) {
    _createQueue.clear();
    _createQueue.addAll(sequences);
    if (_createQueue.isNotEmpty) {
      _handleCreateNode(_createQueue.removeAt(0));
    }
  }

  void _openEditNodeModal(BuildContext context, {int? index}) {
    String nodeId;
    bool isNewNode;
    bool isPrimaryNode = false;
    int totalNodes = _displayNodes.length;
    String? sequence;
    NodeDetail? initialNode;
    int? unsavedSequenceToDelete;

    if (index != null && index < _displayNodes.length) {
      final displayNode = _displayNodes[index];
      isPrimaryNode = index == 0;
      final uiNode = _uiNodes.firstWhere(
        (n) => n.sequence == displayNode.sequence,
        orElse: () => NodeUiState(
          title: displayNode.title,
          description: displayNode.description,
          sequence: displayNode.sequence,
          isCreated: false,
        ),
      );

      final resolvedNodeId = uiNode.realNodeId;
      final hasRealNodeId = resolvedNodeId != null && resolvedNodeId.isNotEmpty;
      final existingNodeId = hasRealNodeId ? resolvedNodeId : null;
      final displayNodeId = displayNode.nodeId.trim();
      final isSyntheticNodeId =
          displayNodeId.startsWith('new_node_') ||
          displayNodeId.startsWith('draft_node_');
      final isBackendNode =
          hasRealNodeId ||
          (!isSyntheticNodeId &&
              (_cachedNodes?.any((n) => n.nodeId == displayNodeId) ?? false));

      if (isBackendNode) {
        // แก้ไข node ที่มีอยู่แล้วจาก backend
        nodeId = existingNodeId ?? displayNodeId;
        isNewNode = false;
        sequence = null;
        initialNode = displayNode;
      } else {
        // AI node ที่ยังไม่ถูกสร้างใน backend
        nodeId = 'new_node_${DateTime.now().millisecondsSinceEpoch}';
        isNewNode = true;
        sequence = displayNode.sequence.toString();
        unsavedSequenceToDelete = displayNode.sequence;
        initialNode = displayNode;
      }
    } else {
      // สร้าง node ใหม่
      nodeId = 'new_node_${DateTime.now().millisecondsSinceEpoch}';
      isNewNode = true;
      final currentNodeCount = _cachedNodes?.length ?? _uiNodes.length;
      sequence = (currentNodeCount + 1).toString();
      initialNode = null;
    }

    final bloc = context.read<LearningPathBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: EditNodeModal(
          nodeId: nodeId,
          isNewNode: isNewNode,
          isAiPath: _isAiPath,
          isPrimaryNode: isPrimaryNode,
          totalNodes: totalNodes,
          pathId: widget.pathId,
          sequence: sequence,
          initialNode: initialNode,
          isReadOnly: _isPublished,
          onDeleteUnsavedNode: unsavedSequenceToDelete == null
              ? null
              : () => _removeUnsavedNodeBySequence(unsavedSequenceToDelete!),
        ),
      ),
    );
  }

  void _removeUnsavedNodeBySequence(int sequence) {
    setState(() {
      _uiNodes.removeWhere(
        (n) => n.realNodeId == null && n.sequence == sequence,
      );
      for (int i = 0; i < _uiNodes.length; i++) {
        _uiNodes[i].sequence = i + 1;
      }
    });
  }

  void _handleAddNodeAfter(int afterIndex) {
    final insertIndex = afterIndex + 1;

    // Create new UI node
    final newNode = NodeUiState(
      title: 'New Node',
      description: '',
      sequence: insertIndex + 1,
      isCreated: false,
    );

    setState(() {
      _uiNodes.insert(insertIndex, newNode);
      // Re-sequence all nodes
      for (int i = 0; i < _uiNodes.length; i++) {
        _uiNodes[i].sequence = i + 1;
      }
    });

    // Open edit modal for the new node
    _openEditNodeModal(context, index: insertIndex);
  }

  void _handleReorder(int fromIndex, int toIndex) {
    setState(() {
      final item = _uiNodes.removeAt(fromIndex);
      _uiNodes.insert(toIndex, item);
      // Update sequences to reflect new order
      for (int i = 0; i < _uiNodes.length; i++) {
        _uiNodes[i].sequence = i + 1;
      }
      // Also reorder cached nodes to keep _displayNodes in sync
      if (_cachedNodes != null && fromIndex < _cachedNodes!.length) {
        final cachedItem = _cachedNodes!.removeAt(fromIndex);
        if (toIndex <= _cachedNodes!.length) {
          _cachedNodes!.insert(toIndex, cachedItem);
        } else {
          _cachedNodes!.add(cachedItem);
        }
      }
    });

    // Sync new order to backend using realNodeIds only (skip draft nodes)
    final orderedNodeIds = _uiNodes
        .where((n) => n.realNodeId != null)
        .map((n) => n.realNodeId!)
        .toList();

    if (orderedNodeIds.isNotEmpty) {
      context.read<LearningPathBloc>().add(
        ReorderNodesEvent(pathId: widget.pathId, nodeIds: orderedNodeIds),
      );
    }

    _scheduleDraftAutoSave();
  }

  void _scheduleDraftAutoSave() {
    // Auto-save draft has been disabled.
    // The learning path status will only change to 'draft' when the user
    // explicitly presses the "Save Draft" button.
    _draftAutoSaveTimer?.cancel();
  }

  void _confirmSaveDraft(BuildContext context) {
    _draftAutoSaveTimer?.cancel();
    LogHandler.info(
      'TeacherNodesOverview: Save Draft tapped (pathId=${widget.pathId})',
    );

    if (_cachedLearningPath == null) {
      _queuedSaveDraftAfterPathLoad = true;
      LogHandler.warning(
        'TeacherNodesOverview: Save Draft queued, learning path detail not loaded yet',
      );
      _fetchLearningPathDetail();
      _startQueuedSaveDraftRetryWatchdog();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preparing save draft... Please wait a moment.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // ป้องกันการ save draft เมื่อเป็น published แล้ว
    if (_cachedLearningPath!.publishStatus.toLowerCase() == 'published') {
      LogHandler.warning(
        'TeacherNodesOverview: Save Draft blocked, path already published',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot save as draft. This learning path is already published.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.cancel,
        ),
      );
      return;
    }

    LogHandler.info(
      'TeacherNodesOverview: Save Draft executing without confirmation',
    );

    // ถ้ายังไม่มี nodes ใน backend ให้สร้างทีละตัวตามลำดับ แล้วค่อย save draft
    final uncreatedSequences = [
      for (int i = 0; i < _uiNodes.length; i++)
        if (!_uiNodes[i].isCreated) _uiNodes[i].sequence,
    ];
    if (uncreatedSequences.isNotEmpty) {
      LogHandler.info(
        'TeacherNodesOverview: Save Draft requires creating ${uncreatedSequences.length} unsaved nodes first',
      );
      _shouldExitAfterPathUpdate = true;
      setState(() => _pendingSaveDraft = true);
      _startSequentialCreate(uncreatedSequences);
      return; // รอ NodeCreated ครบทุกตัวแล้วค่อย dispatch
    }

    _shouldExitAfterPathUpdate = true;
    _requestedPathUpdateStatus = 'draft';
    LogHandler.info(
      'TeacherNodesOverview: Dispatching UpdateLearningPathEvent as draft',
    );
    context.read<LearningPathBloc>().add(
      UpdateLearningPathEvent(
        pathId: widget.pathId,
        title: _cachedLearningPath!.title,
        objective: _cachedLearningPath!.objective,
        description: _cachedLearningPath!.description,
        coverImgUrl: _cachedLearningPath!.coverImageUrl,
        publishStatus: 'draft',
      ),
    );
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.cancel,
      ),
    );
  }

  bool _validateNodesForPublish() {
    final nodes = _displayNodes;

    if (nodes.isEmpty) {
      _showValidationError('Please add at least one node before publishing.');
      return false;
    }

    bool hasIncompleteNode = false;

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];

      // ตรวจสอบฟิลด์ที่บังคับ (ถ้าจะใช้เช็ค Video URL ด้วย ก็เอาคอมเมนต์ออกได้เลยครับ)
      if (node.title.trim().isEmpty ||
          node.description.trim().isEmpty ||
          // node.linkVdo == null || node.linkVdo!.trim().isEmpty ||
          node.questions.isEmpty) {
        
        hasIncompleteNode = true;
        break; // เจอตัวที่ไม่ครบปุ๊บ หยุดลูปทันที เพราะเราแค่ต้องการบอกภาพรวม
      }
    }

    // แจ้งเตือนแบบภาพรวม
    if (hasIncompleteNode) {
      _showValidationError(
        'Please ensure all nodes have complete information.'
      );
      return false;
    }

    return true; 
  }

  void _confirmPublish(BuildContext context) {
    _draftAutoSaveTimer?.cancel();
    LogHandler.info(
      'TeacherNodesOverview: Publish tapped (pathId=${widget.pathId})',
    );

    if (_cachedLearningPath == null) {
      _queuedPublishAfterPathLoad = true;
      LogHandler.warning(
        'TeacherNodesOverview: Publish queued, learning path detail not loaded yet',
      );
      _fetchLearningPathDetail();
      _startQueuedPublishRetryWatchdog();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preparing publish... Please wait a moment.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_cachedLearningPath!.publishStatus.toLowerCase() == 'published') {
      LogHandler.warning(
        'TeacherNodesOverview: Publish blocked, path already published',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This learning path is already published.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.cancel,
        ),
      );
      return;
    }

    if (!_validateNodesForPublish()) {
      return; 
    }

    LogHandler.info(
      'TeacherNodesOverview: Publish executing without confirmation',
    );

    final uncreatedSequences = [
      for (int i = 0; i < _uiNodes.length; i++)
        if (!_uiNodes[i].isCreated) _uiNodes[i].sequence,
    ];
    if (uncreatedSequences.isNotEmpty) {
      LogHandler.info(
        'TeacherNodesOverview: Publish requires creating ${uncreatedSequences.length} unsaved nodes first',
      );
      _shouldExitAfterPathUpdate = true;
      setState(() => _pendingPublish = true);
      _startSequentialCreate(uncreatedSequences);
      return;
    }

    _shouldExitAfterPathUpdate = true;
    _requestedPathUpdateStatus = 'published';
    LogHandler.info(
      'TeacherNodesOverview: Dispatching UpdateLearningPathEvent as published',
    );
    context.read<LearningPathBloc>().add(
      UpdateLearningPathEvent(
        pathId: widget.pathId,
        title: _cachedLearningPath!.title,
        objective: _cachedLearningPath!.objective,
        description: _cachedLearningPath!.description,
        coverImgUrl: _cachedLearningPath!.coverImageUrl,
        publishStatus: 'published',
      ),
    );
  }

  List<NodeDetail> _buildFallbackNodesFromUiState() {
    return _uiNodes
        .map(
          (uiNode) => NodeDetail(
            nodeId: uiNode.realNodeId ?? 'draft_node_${uiNode.sequence}',
            title: uiNode.title,
            description: uiNode.description,
            sequence: uiNode.sequence,
            pathId: widget.pathId,
            materials: const [],
            questions: const [],
            status: 'locked',
            complete: 'false',
            linkVdo: null,
          ),
        )
        .toList();
  }

  bool get _shouldKeepDraftUiNodes {
    return _isAiPath ||
        _uiNodes.any((n) => !n.isCreated) ||
        _pendingPublish ||
        _pendingSaveDraft ||
        _createQueue.isNotEmpty ||
        _pendingNodeIndex != null;
  }

  List<NodeDetail> get _displayNodes {
    final backendNodes = _cachedNodes;
    final cachedNodeIds =
        backendNodes?.map((n) => n.nodeId).toSet() ?? <String>{};

    // Include any _uiNode whose realNodeId is not yet reflected in _cachedNodes.
    // This covers both uncreated draft nodes AND nodes that were just created
    // sequentially but whose realNodeId hasn't appeared in a fresh fetch yet,
    // preventing them from disappearing during the Save Draft sequential flow.
    final pendingUiNodes = _shouldKeepDraftUiNodes
        ? _uiNodes
              .where(
                (n) =>
                    n.realNodeId == null ||
                    !cachedNodeIds.contains(n.realNodeId),
              )
              .toList()
        : <NodeUiState>[];

    if (backendNodes != null && backendNodes.isNotEmpty) {
      if (pendingUiNodes.isEmpty) return backendNodes;

      // Merge backend nodes + pending UI nodes, sorted by sequence
      final merged = [
        ...backendNodes,
        ...pendingUiNodes.map(
          (uiNode) => NodeDetail(
            nodeId: uiNode.realNodeId ?? 'draft_node_${uiNode.sequence}',
            title: uiNode.title,
            description: uiNode.description,
            sequence: uiNode.sequence,
            pathId: widget.pathId,
            materials: const [],
            questions: const [],
            status: 'locked',
            complete: 'false',
            linkVdo: null,
          ),
        ),
      ];
      merged.sort((a, b) => a.sequence.compareTo(b.sequence));
      return merged;
    }
    return _buildFallbackNodesFromUiState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return BlocListener<LearningPathBloc, LearningPathState>(
      listener: (context, state) {
        // Update cached learning path when loaded
        if (state is LearningPathDetailLoaded) {
          _queuedSaveDraftRetryTimer?.cancel();
          _queuedPublishRetryTimer?.cancel();
          setState(() {
            _cachedLearningPath = state.learningPath;
            if (state.learningPath.title.isNotEmpty) {
              _displayTitle = state.learningPath.title;
            }
          });
          LogHandler.info(
            'TeacherNodesOverview: LearningPathDetailLoaded (status=${state.learningPath.publishStatus})',
          );

          if (_queuedSaveDraftAfterPathLoad && !_isPublished) {
            _queuedSaveDraftAfterPathLoad = false;
            LogHandler.info(
              'TeacherNodesOverview: Executing queued Save Draft after detail loaded',
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _confirmSaveDraft(context);
            });
          }

          if (_queuedPublishAfterPathLoad && !_isPublished) {
            _queuedPublishAfterPathLoad = false;
            LogHandler.info(
              'TeacherNodesOverview: Executing queued Publish after detail loaded',
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _confirmPublish(context);
            });
          }
        }

        // Update cached nodes when loaded from backend
        if (state is NodesLoaded && state.pathId == widget.pathId) {
          setState(() {
            _cachedNodes = state.nodes;
            // Rebuild _uiNodes to include ALL backend nodes so that
            // _handleReorder works correctly for both plain path and AI path.
            // Uncreated UI nodes (draft AI nodes not yet saved) are preserved.
            if (state.nodes.isNotEmpty) {
              final newUiNodes = <NodeUiState>[];
              final matchedUiIndices = <int>{};

              int findMatchIndex(NodeDetail backendNode) {
                // 1) Prefer exact real ID match
                for (int i = 0; i < _uiNodes.length; i++) {
                  if (matchedUiIndices.contains(i)) continue;
                  if (_uiNodes[i].realNodeId == backendNode.nodeId) return i;
                }

                // 2) Then match unsaved drafts by sequence + title
                for (int i = 0; i < _uiNodes.length; i++) {
                  if (matchedUiIndices.contains(i)) continue;
                  final ui = _uiNodes[i];
                  if (ui.realNodeId == null &&
                      ui.sequence == backendNode.sequence &&
                      ui.title.trim() == backendNode.title.trim()) {
                    return i;
                  }
                }

                // 3) Fallback to sequence-only for legacy behavior
                for (int i = 0; i < _uiNodes.length; i++) {
                  if (matchedUiIndices.contains(i)) continue;
                  final ui = _uiNodes[i];
                  if (ui.realNodeId == null &&
                      ui.sequence == backendNode.sequence) {
                    return i;
                  }
                }

                return -1;
              }

              for (final backendNode in state.nodes) {
                final existingIndex = findMatchIndex(backendNode);
                if (existingIndex >= 0) {
                  matchedUiIndices.add(existingIndex);
                  _uiNodes[existingIndex].title = backendNode.title;
                  _uiNodes[existingIndex].description = backendNode.description;
                  _uiNodes[existingIndex].sequence = backendNode.sequence;
                  _uiNodes[existingIndex].realNodeId = backendNode.nodeId;
                  _uiNodes[existingIndex].isCreated = true;
                  newUiNodes.add(_uiNodes[existingIndex]);
                } else {
                  // Backend node has no matching UI entry (plain path case):
                  // create a new NodeUiState for it so _uiNodes mirrors all nodes.
                  newUiNodes.add(
                    NodeUiState(
                      title: backendNode.title,
                      description: backendNode.description,
                      sequence: backendNode.sequence,
                      realNodeId: backendNode.nodeId,
                      isCreated: true,
                    ),
                  );
                }
              }

              // Preserve unmatched drafts only when explicitly needed.
              for (int i = 0; i < _uiNodes.length; i++) {
                if (matchedUiIndices.contains(i)) continue;
                final ui = _uiNodes[i];
                if (!ui.isCreated && _shouldKeepDraftUiNodes) {
                  newUiNodes.add(ui);
                }
              }

              newUiNodes.sort((a, b) => a.sequence.compareTo(b.sequence));
              _uiNodes = newUiNodes;
            }
          });
        }

        if (state is NodeDeleted) {
          final deletedNode = _cachedNodes?.cast<NodeDetail?>().firstWhere(
            (n) => n?.nodeId == state.nodeId,
            orElse: () => null,
          );

          // Immediately remove the deleted node from UI
          setState(() {
            _uiNodes.removeWhere((n) => n.realNodeId == state.nodeId);
            if (deletedNode != null) {
              _uiNodes.removeWhere(
                (n) =>
                    n.realNodeId == null && n.sequence == deletedNode.sequence,
              );
            }
            _cachedNodes?.removeWhere((n) => n.nodeId == state.nodeId);
            // Re-sequence remaining nodes
            for (int i = 0; i < _uiNodes.length; i++) {
              _uiNodes[i].sequence = i + 1;
            }
          });

          // Also sync with backend
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _userId != null && _userId!.isNotEmpty) {
              _fetchNodes(_userId!);
            }
          });
        }

        if (state is NodeCreated) {
          LogHandler.info(
            'TeacherNodesOverview: NodeCreated received (${state.nodeId})',
          );
          // Node ถูกสร้างสำเร็จ อัพเดท UI state
          if (_pendingNodeIndex != null) {
            setState(() {
              _uiNodes[_pendingNodeIndex!].realNodeId = state.nodeId;
              _uiNodes[_pendingNodeIndex!].isCreated = true;
              _pendingNodeIndex = null;
            });
          }

          // ถ้ายังมี node ที่ต้องสร้างต่อ ให้ทำทีละตัวตามลำดับก่อน finalize
          if (_createQueue.isNotEmpty) {
            LogHandler.info(
              'TeacherNodesOverview: Continue sequential node creation (${_createQueue.length} remaining)',
            );
            _handleCreateNode(_createQueue.removeAt(0));
            return;
          }

          // ถ้ามี pending publish/draft ให้ dispatch UpdateLearningPathEvent หลังสร้างครบทุก node
          if (_pendingPublish || _pendingSaveDraft) {
            final status = _pendingPublish ? 'published' : 'draft';
            LogHandler.info(
              'TeacherNodesOverview: Dispatching deferred path update (status=$status)',
            );
            setState(() {
              _pendingPublish = false;
              _pendingSaveDraft = false;
            });
            _requestedPathUpdateStatus = status;
            context.read<LearningPathBloc>().add(
              UpdateLearningPathEvent(
                pathId: widget.pathId,
                title: _cachedLearningPath!.title,
                objective: _cachedLearningPath!.objective,
                description: _cachedLearningPath!.description,
                coverImgUrl: _cachedLearningPath!.coverImageUrl,
                publishStatus: status,
              ),
            );
            return;
          }

          _scheduleDraftAutoSave();

          // Refetch nodes with a small delay to ensure backend transaction is committed
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _userId != null && _userId!.isNotEmpty) {
              _fetchNodes(_userId!);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Node created successfully',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.status,
            ),
          );
        } else if (state is NodeUpdated) {
          // Node ถูกอัพเดทสำเร็จ
          if (_pendingNodeIndex != null) {
            setState(() {
              _pendingNodeIndex = null;
            });
          }

          _scheduleDraftAutoSave();

          // Refetch nodes with a small delay to ensure backend transaction is committed
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _userId != null && _userId!.isNotEmpty) {
              _fetchNodes(_userId!);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Node updated successfully',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.status,
            ),
          );
        } else if (state is LearningPathUpdated) {
          LogHandler.success(
            'TeacherNodesOverview: LearningPathUpdated received',
          );

          if (!_shouldExitAfterPathUpdate) {
            return;
          }

          _shouldExitAfterPathUpdate = false;

          final isPublishSuccess = _requestedPathUpdateStatus == 'published';
          _requestedPathUpdateStatus = null;

          // Learning path updated successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPublishSuccess
                    ? 'Learning path published successfully'
                    : 'Learning path updated successfully',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.status,
            ),
          );

          LogHandler.success(
            'TeacherNodesOverview: Save Draft success, leaving current page',
          );

          _allowPopAfterSave = true;

          if (_isAiPath) {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) navigator.pop();
            if (navigator.canPop()) navigator.pop();
            if (navigator.canPop()) navigator.pop();
          } else {
            Navigator.pop(context);
          }
        } else if (state is LearningPathError) {
          _queuedSaveDraftRetryTimer?.cancel();
          LogHandler.error(
            'TeacherNodesOverview: LearningPathError -> ${state.message}',
          );
          setState(() {
            _pendingNodeIndex = null;
            _shouldExitAfterPathUpdate = false;
            _queuedSaveDraftAfterPathLoad = false;
            _requestedPathUpdateStatus = null;
          });

          _allowPopAfterSave = false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.cancel,
            ),
          );
        }
      },
      child: WillPopScope(
        onWillPop: _onWillPopAutoSaveDraft,
        child: Scaffold(
          appBar: const AppBarWidget(
            title: 'Nodes Overview',
            showBackButton: true,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                /// ===== CORE =====
                NodesOverviewCore(
                  isEditable: true,
                  isDraggable: !_isPublished,
                  showAddBetween: !_isPublished,
                  forceLockedStyle: false,
                  showNodeTitle: true,
                  nodes: _displayNodes,
                  onNodeTap: (index) {
                    _openEditNodeModal(context, index: index);
                  },
                  onReorder: _handleReorder,
                  onAddNodeAfter: _handleAddNodeAfter,
                ),

                /// ===== HEADER =====
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: HeaderBar(title: _displayTitle, showAddButton: false),
                ),

                /// ===== FLOATING BOTTOM =====
                Positioned(
                  bottom: bottomInset + 20,
                  left: 0,
                  right: 0,
                  child: Builder(
                    builder: (bottomContext) => BottomBar(
                      onSaveDraft: () => _confirmSaveDraft(bottomContext),
                      onPublish: () => _confirmPublish(bottomContext),
                      isPublished: _isPublished,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


