import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_bottom.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/edit_node_modal.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_core.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/popups/teacher/confirm_popup.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/generated_node.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';

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

  @override
  void initState() {
    super.initState();
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
      // Create Plain Path: สร้าง node เปล่าๆ 1 node
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
        linkvdo: '', // TODO: เพิ่ม link vdo ถ้ามี
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
    int editIndex;

    // ถ้าไม่มี index (กดปุ่ม Add) ให้สร้าง node ใหม่
    if (index == null) {
      final newSequence = _uiNodes.isEmpty ? 1 : _uiNodes.last.sequence + 1;
      final newNode = NodeUiState(
        title: 'New Node',
        description: '',
        sequence: newSequence,
        isCreated: false,
      );

      setState(() {
        _uiNodes.add(newNode);
      });

      editIndex = _uiNodes.length - 1;
    } else {
      editIndex = index;
    }

    final currentNode = _uiNodes[editIndex];
    final bloc = context.read<LearningPathBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: EditNodeModal(
          nodeId: currentNode.realNodeId ?? 'new_node_$editIndex',
        ),
      ),
    );
  }

  void _confirmSaveDraft(BuildContext context) {
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
        debugPrint('Saving draft nodes...');
      },
    );
  }

  void _confirmPublish(BuildContext context) {
    ConfirmPopup.show(
      context,
      title: 'Publish\n Confirmation',
      body: 'Are you sure to publish Learning Path',
      confirmText: 'Publish',
      onConfirm: () {
        // TODO: เรียก API publish learning path
        debugPrint('Publishing learning path: ${widget.pathId}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<LearningPathBloc, LearningPathState>(
      listener: (context, state) {
        if (state is NodeCreated && _pendingNodeIndex != null) {
          // Node ถูกสร้างสำเร็จ อัพเดท UI state
          setState(() {
            _uiNodes[_pendingNodeIndex!].realNodeId = state.nodeId;
            _uiNodes[_pendingNodeIndex!].isCreated = true;
            _pendingNodeIndex = null;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Node created successfully')),
          );
        } else if (state is NodeUpdated && _pendingNodeIndex != null) {
          // Node ถูกอัพเดทสำเร็จ
          setState(() {
            _pendingNodeIndex = null;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Node updated successfully')),
          );
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
