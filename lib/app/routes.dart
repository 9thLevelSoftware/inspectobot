class AppRoutes {
  static const dashboard = '/dashboard';
  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const recoveryScheme = 'inspectobot';
  static const recoveryHost = 'auth';
  static const recoveryPath = '/reset-password';
  static const recoveryCallbackUri =
      '$recoveryScheme://$recoveryHost$recoveryPath';
  static const resetPasswordSuccessMessage =
      'Password updated successfully. Sign in with your new password.';
  static const inspectorIdentity = '/inspector-identity';
  static const auth = '/auth';
  static const newInspection = '/inspections/new';
  static String inspectionChecklist(String id) => '/inspections/$id/checklist';

  const AppRoutes._();
}
