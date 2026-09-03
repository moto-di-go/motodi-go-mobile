part of 'support_cubit.dart';

enum SupportFormStatus { initial, editing, submitting, success }
enum SupportListStatus { initial, loading, loadingMore, success, failure }
enum SupportDetailStatus { initial, loading, success, failure }

class SupportState extends Equatable {
  final SupportFormStatus formStatus;
  final SupportListStatus listStatus;
  final SupportDetailStatus detailStatus;
  final SupportCategory category;
  final SupportPriority priority;
  final String subject;
  final String message;
  final SupportContext? context;
  final SupportTicket? createdTicket;
  final List<SupportTicket> tickets;
  final SupportTicket? selectedTicket;
  final SupportTicketStatus? statusFilter;
  final int page;
  final bool hasMore;
  final String? errorMessage;

  const SupportState({
    this.formStatus = SupportFormStatus.initial,
    this.listStatus = SupportListStatus.initial,
    this.detailStatus = SupportDetailStatus.initial,
    this.category = SupportCategory.transport,
    this.priority = SupportPriority.medium,
    this.subject = '',
    this.message = '',
    this.context,
    this.createdTicket,
    this.tickets = const [],
    this.selectedTicket,
    this.statusFilter,
    this.page = 0,
    this.hasMore = false,
    this.errorMessage,
  });

  SupportState copyWith({
    SupportFormStatus? formStatus,
    SupportListStatus? listStatus,
    SupportDetailStatus? detailStatus,
    SupportCategory? category,
    SupportPriority? priority,
    String? subject,
    String? message,
    SupportContext? context,
    SupportTicket? createdTicket,
    List<SupportTicket>? tickets,
    SupportTicket? selectedTicket,
    SupportTicketStatus? statusFilter,
    int? page,
    bool? hasMore,
    String? errorMessage,
    bool clearContext = false,
    bool clearTickets = false,
    bool clearStatusFilter = false,
  }) {
    return SupportState(
      formStatus: formStatus ?? this.formStatus,
      listStatus: listStatus ?? this.listStatus,
      detailStatus: detailStatus ?? this.detailStatus,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      context: clearContext ? null : (context ?? this.context),
      createdTicket: createdTicket ?? this.createdTicket,
      tickets: clearTickets ? const [] : (tickets ?? this.tickets),
      selectedTicket: selectedTicket ?? this.selectedTicket,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    formStatus,
    listStatus,
    detailStatus,
    category,
    priority,
    subject,
    message,
    context,
    createdTicket,
    tickets,
    selectedTicket,
    statusFilter,
    page,
    hasMore,
    errorMessage,
  ];
}
