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

  const TeacherNodesOverviewPage({
    super.key,
    required this.title,
    this.aiNodes,
    required this.pathId,
  });

  @override
  State<TeacherNodesOverviewPage> createState() =>
      _TeacherNodesOverviewPageState();
}

class _TeacherNodesOverviewPageState extends State<TeacherNodesOverviewPage> {
  late List<NodeUiState> _uiNodes;
  int? _pendingNodeIndex; // เก็บ index ของ node ที่รอ response จาก BLoC
  String? _userId;
  List<NodeDetail>? _cachedNodes; // Cache nodes from backend
  LearningPath? _cachedLearningPath; // Cache learning path details for updating

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchNodes();
    
    // ถ้ามี AI nodes ให้ใช้ ถ้าไม่มีให้สร้าง default node เปล่าๆ
    if (widget.aiNodes != null && widget.aiNodes!.isNotEmpty) {
      _uiNodes = widget.aiNodes!.map((aiNode) {
        return NodeUiState(
          title: aiNode.title,
          description: "",
          sequence: aiNode.sequence,
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
      FetchNodesForPath(pathId: widget.pathId, userId: userId),
    );
  }

  void _fetchLearningPathDetail() {
    // Fetch learning path details for updating publish status
    context.read<LearningPathBloc>().add(
      GetLearningPathByIdEvent(pathId: widget.pathId),
    );
  }

  void _handleCreateNode(int index) {
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

  void _handleUpdateNode(int index, String title, String description) {
    final node = _uiNodes[index];
    
    if (node.realNodeId == null) return;

    setState(() {
      _pendingNodeIndex = index;
    });

    context.read<LearningPathBloc>().add(
      UpdateNodeEvent(
        nodeId: node.realNodeId!,
        title: title,
        description: description,
      ),
    );
  }

  void _openEditNodeModal(BuildContext context, {int? index}) {
    String nodeId;
    bool isNewNode;
    String? sequence;

    // ถ้ามี index (กดที่ node ที่มีอยู่แล้ว)
    if (index != null && _cachedNodes != null && index < _cachedNodes!.length) {
      // แก้ไข node ที่มีอยู่แล้วจาก backend
      nodeId = _cachedNodes![index].nodeId;
      isNewNode = false;
      sequence = null;
    } else {
      // สร้าง node ใหม่
      nodeId = 'new_node_${DateTime.now().millisecondsSinceEpoch}';
      isNewNode = true;
      // กำหนด sequence เป็น node ถัดไปจาก _uiNodes
      sequence = (_uiNodes.length + 1).toString();
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
          pathId: widget.pathId,
          sequence: sequence,
        ),
      ),
    );
  }

  void _confirmSaveDraft(BuildContext context) {
    if (_cachedLearningPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading learning path data...')),
      );
      return;
    }

    ConfirmPopup.show(
      context,
      title: 'Save Draft\n Confirmation',
      body: 'Are you sure to save draft',
      confirmText: 'Save',
      onConfirm: () {
        // สร้าง nodes ที่ยังไม่ได้สร้าง
        for (int i = 0; i < _uiNodes.length; i++) {
          if (!_uiNodes[i].isCreated) {
            _handleCreateNode(i);
          }
        }
        
        // อัปเดต publish status เป็น draft
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
        
        debugPrint('Saving draft...');
      },
    );
  }

  void _confirmPublish(BuildContext context) {
    if (_cachedLearningPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading learning path data...')),
      );
      return;
    }

    ConfirmPopup.show(
      context,
      title: 'Publish\n Confirmation',
      body: 'Are you sure to publish Learning Path',
      confirmText: 'Publish',
      onConfirm: () {
        // สร้าง nodes ที่ยังไม่ได้สร้าง (ถ้ามี)
        for (int i = 0; i < _uiNodes.length; i++) {
          if (!_uiNodes[i].isCreated) {
            _handleCreateNode(i);
          }
        }
        
        // อัปเดต publish status เป็น published
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
        
        debugPrint('Publishing learning path: ${widget.pathId}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<LearningPathBloc, LearningPathState>(
      listener: (context, state) {
        // Update cached learning path when loaded
        if (state is LearningPathDetailLoaded) {
          setState(() {
            _cachedLearningPath = state.learningPath;
          });
        }
        
        // Update cached nodes when loaded from backend
        if (state is NodesLoaded && state.pathId == widget.pathId) {
          setState(() {
            _cachedNodes = state.nodes;
          });
        }
        
        if (state is NodeCreated && _pendingNodeIndex != null) {
          // Node ถูกสร้างสำเร็จ อัพเดท UI state
          setState(() {
            _uiNodes[_pendingNodeIndex!].realNodeId = state.nodeId;
            _uiNodes[_pendingNodeIndex!].isCreated = true;
            _pendingNodeIndex = null;
          });
          
          // Refetch nodes to update display
          if (_userId != null && _userId!.isNotEmpty) {
            _fetchNodes(_userId!);
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Node created successfully')),
          );
        } else if (state is NodeUpdated && _pendingNodeIndex != null) {
          // Node ถูกอัพเดทสำเร็จ
          setState(() {
            _pendingNodeIndex = null;
          });
          
          // Refetch nodes to update display
          if (_userId != null && _userId!.isNotEmpty) {
            _fetchNodes(_userId!);
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Node updated successfully')),
          );
        } else if (state is LearningPathUpdated) {
          // Learning path updated successfully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Learning path updated successfully')),
          );
          
          // Navigate back to previous page - the parent page will handle refetch
          Navigator.pop(context);
        } else if (state is LearningPathError) {
          setState(() {
            _pendingNodeIndex = null;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: const AppBarWidget(title: 'Nodes Overview', showBackButton: true),
        body: SafeArea(
          child: Stack(
            children: [
              /// ===== CORE =====
              NodesOverviewCore(
                isEditable: true,
                nodes: _cachedNodes, // ส่ง nodes จาก backend
                onNodeTap: (index) {
                  _openEditNodeModal(context, index: index);
                },
              ),

              /// ===== HEADER =====
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: HeaderBar(
                  title: widget.title,
                  showAddButton: true,
                  onPressed: () => _openEditNodeModal(context),
                ),
              ),

              /// ===== FLOATING BOTTOM =====
              Positioned(
                top: screenHeight * 0.65,
                left: 0,
                right: 0,
                child: Builder(
                  builder: (bottomContext) => BottomBar(
                    onSaveDraft: () => _confirmSaveDraft(bottomContext),
                    onPublish: () => _confirmPublish(bottomContext),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
