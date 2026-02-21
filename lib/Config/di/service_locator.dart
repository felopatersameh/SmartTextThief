import 'package:get_it/get_it.dart';

import '../../Features/Exams/create_exam/data/datasources/create_exam_remote_data_source.dart';
import '../../Features/Exams/create_exam/data/repositories/create_exam_repository.dart';
import '../../Features/Exams/do_exam/data/datasources/do_exam_remote_data_source.dart';
import '../../Features/Exams/do_exam/data/repositories/do_exam_repository.dart';
import '../../Features/Exams/view_exam/data/datasources/view_exam_remote_data_source.dart';
import '../../Features/Exams/view_exam/data/repositories/view_exam_repository.dart';
import '../../Features/Main/cubit/main_cubit.dart';
import '../../Features/Notifications/Presentation/cubit/notifications_cubit.dart';
import '../../Features/Profile/Persentation/cubit/profile_cubit.dart';
import '../../Features/Subjects/Data/datasources/subjects_remote_data_source.dart';
import '../../Features/Subjects/Data/repositories/subject_repository_impl.dart';
import '../../Features/Subjects/Domain/repositories/subject_repository.dart';
import '../../Features/Subjects/Domain/usecases/search_subjects_use_case.dart';
import '../../Features/Subjects/Persentation/cubit/subjects_cubit.dart';
import '../../Features/login/Persentation/Cubit/authentication_cubit.dart';
import '../Setting/settings_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  _registerLazySingleton<SubjectsRemoteDataSource>(
    SubjectsRemoteDataSource.new,
  );
  _registerLazySingleton<SubjectRepository>(
    () => SubjectRepositoryImpl(
      remoteDataSource: getIt<SubjectsRemoteDataSource>(),
    ),
  );
  _registerLazySingleton<SearchSubjectsUseCase>(SearchSubjectsUseCase.new);

  _registerLazySingleton<CreateExamRemoteDataSource>(
    CreateExamRemoteDataSource.new,
  );
  _registerLazySingleton<CreateExamRepository>(
    () => CreateExamRepository(
      remoteDataSource: getIt<CreateExamRemoteDataSource>(),
    ),
  );

  _registerLazySingleton<ViewExamRemoteDataSource>(
    ViewExamRemoteDataSource.new,
  );
  _registerLazySingleton<ViewExamRepository>(
    () => ViewExamRepository(
      remoteDataSource: getIt<ViewExamRemoteDataSource>(),
    ),
  );

  _registerLazySingleton<DoExamRemoteDataSource>(
    DoExamRemoteDataSource.new,
  );
  _registerLazySingleton<DoExamRepository>(
    () => DoExamRepository(
      remoteDataSource: getIt<DoExamRemoteDataSource>(),
    ),
  );

  _registerLazySingleton<SettingsCubit>(SettingsCubit.new);
  _registerLazySingleton<ProfileCubit>(ProfileCubit.new);
  _registerLazySingleton<SubjectCubit>(
    () => SubjectCubit(
      repository: getIt<SubjectRepository>(),
      searchSubjectsUseCase: getIt<SearchSubjectsUseCase>(),
    ),
  );
  _registerLazySingleton<NotificationsCubit>(NotificationsCubit.new);

  _registerFactory<MainCubit>(MainCubit.new);
  _registerFactory<AuthenticationCubit>(AuthenticationCubit.new);
}

void _registerLazySingleton<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerLazySingleton<T>(factory);
  }
}

void _registerFactory<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerFactory<T>(factory);
  }
}
