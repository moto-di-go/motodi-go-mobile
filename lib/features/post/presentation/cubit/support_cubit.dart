import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/domain/repositories/post_repository.dart';

part 'support_state.dart';

@injectable
class SupportCubit extends Cubit<SupportState> {
  final PostRepository _repository;
  static const _pageSize = 20;

  SupportCubit(this._repository) : super(const SupportState());

  void initForm({SupportContext? context}) {
    emit(
      state.copyWith(
        formStatus: SupportFormStatus.editing,
        context: context,
        clearContext: context == null,
        category: SupportCategory.transport,
        priority: SupportPriority.medium,
        subject: '',
        message: '',
        errorMessage: null,
        createdTicket: null,
      ),
    );
  }

  void setCategory(SupportCategory category) {
    emit(state.copyWith(category: category));
  }

  void setPriority(SupportPriority priority) {
    emit(state.copyWith(priority: priority));
  }

  void setSubject(String subject) {
    emit(state.copyWith(subject: subject));
  }

  void setMessage(String message) {
    emit(state.copyWith(message: message));
  }

  Future<void> submit() async {
    final subject = state.subject.trim();
    final message = state.message.trim();
    if (subject.isEmpty || message.isEmpty) {
      emit(state.copyWith(errorMessage: 'Sujet et message sont obligatoires.'));
      return;
    }

    emit(state.copyWith(formStatus: SupportFormStatus.submitting, errorMessage: null));
    final result = await _repository.createSupportTicket(
      category: state.category,
      priority: state.priority,
      subject: subject,
      message: message,
      tripId: state.context?.tripId,
      bookingId: state.context?.bookingId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(formStatus: SupportFormStatus.editing, errorMessage: failure.message));
      },
      (ticket) => emit(
        state.copyWith(
          formStatus: SupportFormStatus.success,
          createdTicket: ticket,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> loadTickets({SupportTicketStatus? status}) async {
    emit(
      state.copyWith(
        listStatus: SupportListStatus.loading,
        statusFilter: status,
        clearStatusFilter: status == null,
        clearTickets: true,
        errorMessage: null,
      ),
    );
    final result = await _repository.getSupportTickets(status: status, page: 0, size: _pageSize);
    result.fold(
      (failure) => emit(
        state.copyWith(listStatus: SupportListStatus.failure, errorMessage: failure.message),
      ),
      (data) => emit(
        state.copyWith(
          listStatus: SupportListStatus.success,
          tickets: data.tickets,
          page: data.page,
          hasMore: data.hasMore,
        ),
      ),
    );
  }

  Future<void> refreshTickets() => loadTickets(status: state.statusFilter);

  Future<void> loadMoreTickets() async {
    if (!state.hasMore || state.listStatus == SupportListStatus.loadingMore) return;
    emit(state.copyWith(listStatus: SupportListStatus.loadingMore));
    final next = state.page + 1;
    final result = await _repository.getSupportTickets(
      status: state.statusFilter,
      page: next,
      size: _pageSize,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(listStatus: SupportListStatus.success, errorMessage: failure.message)),
      (data) => emit(
        state.copyWith(
          listStatus: SupportListStatus.success,
          tickets: [...state.tickets, ...data.tickets],
          page: data.page,
          hasMore: data.hasMore,
        ),
      ),
    );
  }

  Future<void> loadTicketDetail(String id) async {
    emit(state.copyWith(detailStatus: SupportDetailStatus.loading, errorMessage: null));
    final result = await _repository.getSupportTicket(id);
    result.fold(
      (failure) => emit(
        state.copyWith(detailStatus: SupportDetailStatus.failure, errorMessage: failure.message),
      ),
      (ticket) => emit(
        state.copyWith(detailStatus: SupportDetailStatus.success, selectedTicket: ticket),
      ),
    );
  }
}
