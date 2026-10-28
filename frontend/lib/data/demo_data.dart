import 'package:flutter/material.dart';

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

  ApprovalItem({
    required this.id,
    required this.title,
    required this.category,
    required this.requestedBy,
    required this.amountOrImpact,
    required this.status,
    required this.date,
  });

  ApprovalItem copyWith({String? status}) {
    return ApprovalItem(
      id: id,
      title: title,
      category: category,
      requestedBy: requestedBy,
      amountOrImpact: amountOrImpact,
      status: status ?? this.status,
      date: date,
    );
  }
}

class CentriaDemoData extends ChangeNotifier {
  static final CentriaDemoData instance = CentriaDemoData._();
  CentriaDemoData._();

  final String companyName = 'Acme Global Ltd';
  final String companyJurisdiction = 'UK #0912481';
  final String currentUser = 'Sarah Jenkins';
  final String currentRole = 'Founder & Executive Director';

  // Tasks
  List<TaskItem> tasks = [
    TaskItem(
      id: 'TSK-101',
      title: 'HMRC CT600 Annual Corporation Tax Submission',
      subtitle: 'Slaughter & May opinion attached · Statutory deadline in 8 days',
      priority: 'CRITICAL',
      status: 'In Progress',
      assignee: 'Sarah Jenkins',
      dueDate: 'Nov 05, 2026',
    ),
    TaskItem(
      id: 'TSK-102',
      title: 'DORA Digital Operational Resilience Act Attestation',
      subtitle: 'ICT third-party risk framework & incident ledger verification',
      priority: 'HIGH',
      status: 'Pending Review',
      assignee: 'David Vance (CISO)',
      dueDate: 'Nov 12, 2026',
    ),
    TaskItem(
      id: 'TSK-103',
      title: 'KVK Netherlands Subsidiary Director Ratification',
      subtitle: 'Acme EU Technologies B.V. annual filings resolution pack',
      priority: 'HIGH',
      status: 'Pending Sign-Off',
      assignee: 'Elena Rostova (GC)',
      dueDate: 'Nov 18, 2026',
    ),
    TaskItem(
      id: 'TSK-104',
      title: 'RemCo LTIP Tranche 3 Vesting Allocation',
      subtitle: 'Audit Merkle proof generation & option pool capacity check',
      priority: 'MEDIUM',
      status: 'Ready to Execute',
      assignee: 'Remuneration Committee',
      dueDate: 'Nov 30, 2026',
    ),
  ];

  // Approvals
  List<ApprovalItem> approvals = [
    ApprovalItem(
      id: 'APP-901',
      title: 'Execute GBP/EUR Forward Collar #FWD-882',
      category: 'Treasury & FX',
      requestedBy: 'AI Cognitive Copilot (98% Conf)',
      amountOrImpact: '£1,200,000 Notional · Strike 1.1740',
      status: 'Pending',
      date: 'Today, 09:14 AM',
    ),
    ApprovalItem(
      id: 'APP-902',
      title: 'Authorize CT600 Corporation Tax Statutory Return',
      category: 'Statutory Tax',
      requestedBy: 'PwC Tax Services & Treasury',
      amountOrImpact: '€412,850 Tax Settlement',
      status: 'Pending',
      date: 'Today, 08:30 AM',
    ),
    ApprovalItem(
      id: 'APP-903',
      title: 'Rotate AWS STS & Breached mTLS Ingestion Key',
      category: 'Security & API',
      requestedBy: 'Automated Enclave Watchdog',
      amountOrImpact: 'Critical Breach Prevention',
      status: 'Pending',
      date: 'Yesterday, 18:22',
    ),
    ApprovalItem(
      id: 'APP-904',
      title: 'Acme EU Technologies B.V. KVK Registry Renewal',
      category: 'Legal Entity',
      requestedBy: 'General Counsel',
      amountOrImpact: 'Amsterdam Hub Compliance',
      status: 'Executed',
      date: 'Oct 24, 2026',
    ),
  ];

  void updateApprovalStatus(String id, String newStatus) {
    tasks = tasks.map((t) => t.id == id ? t.copyWith(status: newStatus) : t).toList();
    approvals = approvals.map((a) => a.id == id ? a.copyWith(status: newStatus) : a).toList();
    notifyListeners();
  }

  void completeTask(String id) {
    tasks = tasks.map((t) => t.id == id ? t.copyWith(status: 'Completed') : t).toList();
    notifyListeners();
  }
}
