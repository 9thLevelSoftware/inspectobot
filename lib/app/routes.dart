class AppRoutes {
  static const authGate = '/';
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

  // New route paths for go_router
  static const auth = '/auth';
  static const newInspection = '/inspections/new';
  static String inspectionChecklist(String id) => '/inspections/$id/checklist';

  /// Auth route set — preserved for backward compatibility until Wave 3.
  static const authStack = <String>{
    signIn,
    signUp,
    forgotPassword,
    resetPassword,
  };

  const AppRoutes._();
}
