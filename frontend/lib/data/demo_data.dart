import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TaskItem {
  final String id;
  final String title;
  final String subtitle;
  final String priority;
  final String status;
  final String assignee;
  final String dueDate;

  TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.status,
    required this.assignee,
    required this.dueDate,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id']?.toString() ?? json['task_code'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      priority: json['priority'] ?? 'MEDIUM',
      status: json['status'] ?? 'TODO',
      assignee: json['assignee_name'] ?? 'Sarah Jenkins',
      dueDate: json['due_date'] ?? 'Nov 15, 2026',
    );
  }

  TaskItem copyWith({String? status}) {
    return TaskItem(
      id: id,
      title: title,
      subtitle: subtitle,
      priority: priority,
      status: status ?? this.status,
      assignee: assignee,
      dueDate: dueDate,
    );
  }
}

class ApprovalItem {
  final String id;
  final String title;
  final String category;
  final String requestedBy;
  final String amountOrImpact;
  final String status;
  final String date;
  final String? signatureHash;

  ApprovalItem({
    required this.id,
    required this.title,
    required this.category,
    required this.requestedBy,
    required this.amountOrImpact,
    required this.status,
    required this.date,
    this.signatureHash,
  });

  factory ApprovalItem.fromJson(Map<String, dynamic> json) {
    return ApprovalItem(
      id: json['id']?.toString() ?? json['approval_code'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'GST_TAX',
      requestedBy: json['requested_by'] ?? 'Audit Enclave',
      amountOrImpact: json['amount_or_impact'] ?? '₹0',
      status: json['status'] ?? 'PENDING',
      date: json['date_display'] ?? 'Today, 09:14 AM',
      signatureHash: json['signature_hash'],
    );
  }

  ApprovalItem copyWith({String? status, String? signatureHash}) {
    return ApprovalItem(
      id: id,
      title: title,
      category: category,
      requestedBy: requestedBy,
      amountOrImpact: amountOrImpact,
      status: status ?? this.status,
      date: date,
      signatureHash: signatureHash ?? this.signatureHash,
    );
  }
}

class CentriaDemoData extends ChangeNotifier {
  static final CentriaDemoData instance = CentriaDemoData._();
  CentriaDemoData._();

  final String companyName = 'Centria Technologies India Pvt Ltd';
  final String companyJurisdiction = 'CIN: U72900KA2024PTC189201 · ROC Bangalore';
  final String gstin = '29AABCC1234F1Z5';
  final String pan = 'AABCC1234F';
  final String currentUser = 'Sarah Jenkins';
  final String currentRole = 'Director (DIN #09124819)';

  bool isSyncingWithBackend = false;
  String? lastBackendSyncTime;
  String? backendConnectionStatus = 'Connecting...';

  // Indian Corporate Tasks
  List<TaskItem> tasks = [
    TaskItem(
      id: 'TSK-IN-101',
      title: 'MCA Form AOC-4 & MGT-7 Annual Filing Ratification',
      subtitle: 'Statutory audit pack prepared by BSR & Co. · Deadline in 8 days',
      priority: 'CRITICAL',
      status: 'In Progress',
      assignee: 'Sarah Jenkins (Director)',
      dueDate: 'Nov 05, 2026',
    ),
    TaskItem(
      id: 'TSK-IN-102',
      title: 'GST GSTR-3B Monthly Return & ITC Reconciliation',
      subtitle: 'Input Tax Credit auto-reconciled against GSTR-2B portal feed',
      priority: 'HIGH',
      status: 'Pending Review',
      assignee: 'Rahul Sharma (CFO)',
      dueDate: 'Nov 20, 2026',
    ),
    TaskItem(
      id: 'TSK-IN-103',
      title: 'ITD Q3 Advance Tax & TDS Section 194J Provisioning',
      subtitle: 'Payment challan generation for ₹35,00,000 quarterly liability',
      priority: 'HIGH',
      status: 'Pending Sign-Off',
      assignee: 'BSR & Co. (Tax Advisory)',
      dueDate: 'Dec 15, 2026',
    ),
    TaskItem(
      id: 'TSK-IN-104',
      title: 'EPFO & ESIC Statutory Remittance for 142 Employees',
      subtitle: 'Electronic Challan cum Return (ECR) ready for biometric approval',
      priority: 'MEDIUM',
      status: 'Ready to Execute',
      assignee: 'Pooja Nair (Head of People Ops)',
      dueDate: 'Nov 15, 2026',
    ),
  ];

  // Sovereign Approvals
  List<ApprovalItem> approvals = [
    ApprovalItem(
      id: 'APP-IN-901',
      title: 'Execute HDFC Forward Collar Contract #INR-FWD-401',
      category: 'Treasury & FX',
      requestedBy: 'AI Copilot (99.2% Conf) · Treasury Desk',
      amountOrImpact: '₹8,50,00,000 Notional · USD/INR 84.15 Strike',
      status: 'Pending',
      date: 'Today, 09:14 AM',
    ),
    ApprovalItem(
      id: 'APP-IN-902',
      title: 'Authorize GST GSTR-3B Monthly Tax Challan Payment',
      category: 'GST & Direct Taxes',
      requestedBy: 'CFO Rahul Sharma & PwC India',
      amountOrImpact: '₹18,40,250 Tax Settlement',
      status: 'Pending',
      date: 'Today, 08:30 AM',
    ),
    ApprovalItem(
      id: 'APP-IN-903',
      title: 'Rotate Razorpay Enterprise Ingestion Webhook Secret',
      category: 'Security & API Infrastructure',
      requestedBy: 'Automated Enclave Sentinel Watchdog',
      amountOrImpact: 'Zero-Downtime Key Rotation',
      status: 'Pending',
      date: 'Yesterday, 18:22 IST',
    ),
    ApprovalItem(
      id: 'APP-IN-904',
      title: 'Ratify Form DIR-12 for Additional Director Appointment',
      category: 'MCA & ROC Statutory',
      requestedBy: 'Company Secretary & Legal Counsel',
      amountOrImpact: 'ROC Bangalore Statutory Record',
      status: 'Executed',
      date: 'Oct 24, 2026',
      signatureHash: '0x9a8f2c3b4e5d6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b',
    ),
  ];

  Future<void> fetchLiveFromBackend() async {
    isSyncingWithBackend = true;
    notifyListeners();
    try {
      final backendTasks = await ApiService.getTasks();
      if (backendTasks.isNotEmpty) {
        tasks = backendTasks.map((t) => TaskItem.fromJson(t)).toList();
      }
      final backendApprovals = await ApiService.getApprovals();
      if (backendApprovals.isNotEmpty) {
        approvals = backendApprovals.map((a) => ApprovalItem.fromJson(a)).toList();
      }
      backendConnectionStatus = 'Sovereign Enclave Live (Neon PostgreSQL)';
      lastBackendSyncTime = 'Synchronized with Neon DB (Asia/Kolkata)';
    } catch (e) {
      backendConnectionStatus = 'Offline / Local Enclave Cache Active';
    } finally {
      isSyncingWithBackend = false;
      notifyListeners();
    }
  }

  void updateApprovalStatus(String id, String newStatus) {
    tasks = tasks.map((t) => t.id == id ? t.copyWith(status: newStatus) : t).toList();
    approvals = approvals.map((a) => a.id == id ? a.copyWith(status: newStatus) : a).toList();
    notifyListeners();

    // Fire non-blocking backend execution if it's an approval
    if (newStatus == 'Executed' || newStatus == 'Approved') {
      ApiService.executeApproval(id, action: 'APPROVE').catchError((_) => <String, dynamic>{});
    }
  }

  void completeTask(String id) {
    tasks = tasks.map((t) => t.id == id ? t.copyWith(status: 'Completed') : t).toList();
    notifyListeners();

    // Fire backend update
    ApiService.updateTask(id, {'status': 'COMPLETED'}).catchError((_) => <String, dynamic>{});
  }
}
