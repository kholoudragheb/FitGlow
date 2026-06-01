import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../data/datasources/rate_coach_remote_datasource.dart';
import '../../data/repositories/rate_coach_repository_impl.dart';
import '../../domain/usecases/rate_coach_usecase.dart';
import '../cubit/rate_coach_cubit.dart';
import '../cubit/rate_coach_state.dart';

class RateCoachScreen extends StatelessWidget {
  final String coachId;
  final String coachName;

  const RateCoachScreen({
    super.key,
    required this.coachId,
    required this.coachName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RateCoachCubit(
        rateCoachUseCase: RateCoachUseCase(
          RateCoachRepositoryImpl(
            RateCoachRemoteDataSourceImpl(Dio()),
          ),
        ),
      ),
      child: RateCoachView(coachId: coachId, coachName: coachName),
    );
  }
}

class RateCoachView extends StatefulWidget {
  final String coachId;
  final String coachName;

  const RateCoachView({
    super.key,
    required this.coachId,
    required this.coachName,
  });

  @override
  State<RateCoachView> createState() => _RateCoachViewState();
}

class _RateCoachViewState extends State<RateCoachView> {
  int _currentRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitRating() {
    final comment = _commentController.text.trim();
    context.read<RateCoachCubit>().submitRating(
      coachId: widget.coachId,
      rating: _currentRating,
      comment: comment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rate Coach',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<RateCoachCubit, RateCoachState>(
        listener: (context, state) {
          if (state is RateCoachSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you! Your rating has been submitted.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Pop back on success
          } else if (state is RateCoachError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'How was your experience with ${widget.coachName}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      iconSize: 48,
                      icon: Icon(
                        starIndex <= _currentRating ? Icons.star : Icons.star_border,
                        color: const Color(0xFFD0FD3E),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentRating = starIndex;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Comment Field
                const Text(
                  'Leave a comment (optional)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F272D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Write your feedback here...',
                      hintStyle: TextStyle(color: Color(0xFFA09D9D)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Submit Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (state is RateCoachLoading || _currentRating == 0)
                        ? null
                        : _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD0FD3E),
                      disabledBackgroundColor: const Color(0xFFD0FD3E).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state is RateCoachLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit Rating',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
