import 'package:get/get.dart';
import 'package:saksi_app/app/screens/get_started.dart';

import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';
import '../modules/backup/bindings/backup_binding.dart';
import '../modules/backup/views/backup_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/admin_contacts_view.dart';
import '../modules/chat/views/chat_list_view.dart';
import '../modules/chat/views/chat_list_view_admin.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/complaint/bindings/complaint_binding.dart';
import '../modules/complaint/views/complaint_view.dart';
import '../modules/dashboard/dashboardAdmin/bindings/dashboard_admin_binding.dart';
import '../modules/dashboard/dashboardAdmin/views/dashboard_admin_view.dart';
import '../modules/dashboard/dashboardSuperadmin/bindings/dashboard_superadmin_binding.dart';
import '../modules/dashboard/dashboardSuperadmin/views/dashboard_superadmin_view.dart';
import '../modules/dashboard/dashboardUser/bindings/dashboard_user_binding.dart';
import '../modules/dashboard/dashboardUser/views/dashboard_user_view.dart';
import '../modules/guide/bindings/guide_binding.dart';
import '../modules/guide/views/guide_view.dart';
import '../modules/manageComplaint/bindings/manage_complaint_binding.dart';
import '../modules/manageComplaint/views/complaint_list_view.dart';
import '../modules/manageComplaint/views/detail_complaint_view.dart';
import '../modules/manageComplaint/views/manage_complaint_view.dart';
import '../modules/manageRole/manageAdmin/bindings/manage_admin_binding.dart';
import '../modules/manageRole/manageAdmin/views/manage_admin_view.dart';
import '../modules/manageRole/manageUser/bindings/manage_user_binding.dart';
import '../modules/manageRole/manageUser/views/manage_user_view.dart';
import '../modules/news/bindings/news_binding.dart';
import '../modules/news/views/add_news_view.dart';
import '../modules/news/views/news_detail_view.dart';
import '../modules/news/views/news_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/progresComplaint/bindings/progres_complaint_binding.dart';
import '../modules/progresComplaint/views/detailRiwayatTab.dart';
import '../modules/progresComplaint/views/progres_complaint_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.GET_STARTED,
      page: () => const GetStartedScreen(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD_USER,
      page: () => const DashboardUserView(),
      binding: DashboardUserBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD_ADMIN,
      page: () => const DashboardAdminView(),
      binding: DashboardAdminBinding(),
    ),
    GetPage(
      name: _Paths.COMPLAINT,
      page: () => const ComplaintView(),
      binding: ComplaintBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_LIST,
      page: () => const ChatListView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_LIST_ADMIN,
      page: () => const ChatListViewAdmin(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_CONTACTS,
      page: () => const AdminContactsView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.PROGRES_COMPLAINT,
      page: () => const ProgresComplaintView(),
      binding: ProgresComplaintBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD_SUPERADMIN,
      page: () => const DashboardSuperadminView(),
      binding: DashboardSuperadminBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_USER,
      page: () => const ManageUserView(),
      binding: ManageUserBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_ADMIN,
      page: () => const ManageAdminView(),
      binding: ManageAdminBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_COMPLAINT,
      page: () => const ManageComplaintView(),
      binding: ManageComplaintBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_COMPLAINT,
      page: () => const DetailComplaintView(),
    ),

    //manual
    GetPage(
      name: _Paths.COMPLAINT_LIST,
      page: () => ComplaintListView(
          statusFilter: Get.arguments.statusFilter, title: Get.arguments.title),
    ),

    GetPage(
      name: _Paths.DETAIL_RIWAYAT,
      page: () => const DetailRiwayatTab(),
    ),
    GetPage(
      name: _Paths.BACKUP,
      page: () => const BackupView(),
      binding: BackupBinding(),
    ),
    GetPage(
      name: _Paths.NEWS,
      page: () => const NewsView(),
      binding: NewsBinding(),
    ),
    GetPage(
      name: _Paths.NEWS_DETAIL,
      page: () => NewsDetailView(news: Get.arguments),
      binding: NewsBinding(),
    ),
    GetPage(
      name: _Paths.ADD_NEWS,
      page: () => const AddNewsView(),
      binding: NewsBinding(),
    ),
    GetPage(
      name: _Paths.GUIDE,
      page: () => const GuideView(),
      binding: GuideBinding(),
    ),
  ];
}
