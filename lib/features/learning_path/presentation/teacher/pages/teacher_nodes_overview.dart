import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_bottom.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/edit_node_modal.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_core.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/popups/teacher/confirm_popup.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/ai_generate_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_node_request.dart';
import 'package:passion_tree_frontend/features/learning_path/data/services/learning_path_api_service.dart';

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
  final List<GeneratedNode> aiNodes;
  final String pathId;

  const TeacherNodesOverviewPage({
    super.key,
    required this.title,
    required this.aiNodes,
    required this.pathId,
  });

  @override
  State<TeacherNodesOverviewPage> createState() =>
      _TeacherNodesOverviewPageState();
}

class _TeacherNodesOverviewPageState extends State<TeacherNodesOverviewPage> {
  late List<NodeUiState> _uiNodes;

  @override
  void initState() {
    super.initState();
    _uiNodes = widget.aiNodes.map((aiNode) {
      return NodeUiState(
        title: aiNode.title,
        description: "",
        sequence: aiNode.sequence,
        isCreated: false,
      );
    }).toList();
  }

  Future<void> _handleSaveNode(
    int index,
    String title,
    String desc,
    List<String> links,
    List<CreateQuestionWithChoicesRequest> questions,
  ) async {
    final currentNode = _uiNodes[index];

    try {
      if (currentNode.isCreated && currentNode.realNodeId != null) {
        await updateNodeApi(currentNode.realNodeId!, title, desc);
        debugPrint('Updated Node: ${currentNode.realNodeId}');
      } else {
        List<CreateMaterialRequest> materials = links.map((url) {
          return CreateMaterialRequest(type: 'link', url: url);
        }).toList();

        final request = CreateNodeRequest(
          title: title,
          description: desc,
          pathId: widget.pathId,
          sequence: currentNode.sequence.toString(),
          materials: materials,
          questions: questions,
        );

        final newNodeId = await createNodeApi(request);

        setState(() {
          currentNode.realNodeId = newNodeId;
          currentNode.isCreated = true;
        });
        debugPrint('Created Node: $newNodeId');
      }

      setState(() {
        currentNode.title = title;
        currentNode.description = desc;
      });
    } catch (e) {
      debugPrint('Error saving node: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _openEditNodeModal(BuildContext context, {int? index}) {
    if (index == null)
      return;

    final node = _uiNodes[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditNodeModal(
        initialTitle: node.title,
        onSaveData: (newTitle, newDesc, newLinks, newQuestions) {
          _handleSaveNode(index, newTitle, newDesc, newLinks, newQuestions);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const AppBarWidget(title: 'Nodes Overview', showBackButton: true),
      body: SafeArea(
        child: Stack(
          children: [
            /// ===== CORE =====
            NodesOverviewCore(
              isEditable: true,
              nodeUiList: _uiNodes,
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
    );
  }

  void _confirmSaveDraft(BuildContext context) {
    ConfirmPopup.show(
      context,
      title: 'Save Draft\n Confirmation',
      body: 'Are you sure to save draft',
      confirmText: 'Save',
      onConfirm: () {
        debugPrint('Save draft nodes');
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
        debugPrint('Publish learning path');
      },
    );
  }
}
