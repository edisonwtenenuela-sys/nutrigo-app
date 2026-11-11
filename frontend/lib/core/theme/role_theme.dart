import 'package:flutter/material.dart';

class RolePalette {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color text;
  final Color mutedText;
  final Color headerStart;
  final Color headerEnd;
  final Color shadow;

  const RolePalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.text,
    required this.mutedText,
    required this.headerStart,
    required this.headerEnd,
    required this.shadow,
  });

  LinearGradient get headerGradient {
    return LinearGradient(
      colors: [headerStart, headerEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color softPrimary([double alpha = 0.10]) {
    return primary.withValues(alpha: alpha);
  }

  Color softSecondary([double alpha = 0.10]) {
    return secondary.withValues(alpha: alpha);
  }
}

class RoleTheme {
  static const brandName = 'NutriGo';

  static const brandPrimary = Color(0xFF0F4C81);
  static const brandSecondary = Color(0xFF5B7F95);
  static const brandSoft = Color(0xFFB4C6E7);
  static const brandBackground = Color(0xFFF6F8FC);
  static const brandSurface = Colors.white;
  static const brandSurfaceTint = Color(0xFFEAF1F8);
  static const brandBadgeBackground = Color(0xFFE6EDFA);
  static const brandChipBackground = Color(0xFFF1F5FA);
  static const brandBorder = Color(0xFFD9E4EF);
  static const brandText = Color(0xFF172033);
  static const brandMutedText = Color(0xFF5B6B7B);

  static const iconHealth = Color(0xFF3F7E68);
  static const iconCalendar = Color(0xFF2F6FED);
  static const iconOrders = Color(0xFF5B7F95);
  static const iconCart = Color(0xFF2F7D8C);
  static const iconStore = Color(0xFF3B78B4);
  static const iconValidation = Color(0xFF2F8F6B);
  static const iconProfile = Color(0xFF5B7F95);
  static const iconWarning = Color(0xFFE18A2F);
  static const iconDanger = Color(0xFFD9534F);
  static const iconInfo = Color(0xFF0F4C81);
  static const iconPayments = Color(0xFF2F8F6B);
  static const iconPromotion = Color(0xFFC47A2C);
  static const iconStatistics = Color(0xFF4F6FA8);
  static const iconLocation = Color(0xFF3B78B4);
  static const iconCommunication = Color(0xFF2F8F6B);
  static const iconSecurity = Color(0xFF516A9A);
  static const iconRating = Color(0xFFD89B20);

  static Color iconColorFor(IconData icon, {Color fallback = iconInfo}) {
    if ({
      Icons.calendar_month_rounded,
      Icons.calendar_today_rounded,
      Icons.calendar_today_outlined,
      Icons.calendar_today,
      Icons.calendar_month_outlined,
      Icons.event_rounded,
      Icons.event_available_rounded,
      Icons.schedule_rounded,
      Icons.access_time_rounded,
      Icons.date_range_rounded,
      Icons.timelapse_rounded,
      Icons.event_note_rounded,
      Icons.edit_calendar_rounded,
      Icons.event_busy_rounded,
      Icons.history_rounded,
    }.contains(icon)) {
      return iconCalendar;
    }

    if ({
      Icons.restaurant_rounded,
      Icons.restaurant_menu_rounded,
      Icons.fastfood_rounded,
      Icons.local_dining_rounded,
      Icons.eco_rounded,
      Icons.spa_rounded,
      Icons.egg_alt_rounded,
      Icons.health_and_safety_rounded,
      Icons.medical_services_rounded,
      Icons.monitor_heart_rounded,
      Icons.favorite_rounded,
      Icons.favorite_outline_rounded,
      Icons.health_and_safety_outlined,
      Icons.local_cafe_rounded,
      Icons.breakfast_dining_rounded,
      Icons.dinner_dining_rounded,
      Icons.lunch_dining_rounded,
      Icons.rice_bowl_rounded,
      Icons.emoji_food_beverage_rounded,
      Icons.no_food_rounded,
    }.contains(icon)) {
      return iconHealth;
    }

    if ({
      Icons.soup_kitchen_rounded,
      Icons.local_fire_department_rounded,
      Icons.local_fire_department_outlined,
    }.contains(icon)) {
      return iconWarning;
    }

    if ({Icons.local_drink_rounded}.contains(icon)) {
      return iconCart;
    }

    if ({Icons.cake_rounded, Icons.cookie_rounded}.contains(icon)) {
      return iconPromotion;
    }

    if ({Icons.fitness_center_rounded, Icons.list_alt_rounded}.contains(icon)) {
      return iconStatistics;
    }

    if ({
      Icons.store_rounded,
      Icons.storefront_rounded,
      Icons.store_mall_directory_rounded,
      Icons.shop_rounded,
      Icons.shop_outlined,
      Icons.shopping_basket_rounded,
      Icons.business_rounded,
    }.contains(icon)) {
      return iconStore;
    }

    if ({
      Icons.shopping_cart_rounded,
      Icons.shopping_cart_outlined,
      Icons.shopping_bag_rounded,
      Icons.shopping_bag_outlined,
      Icons.shopping_cart,
      Icons.shopping_cart_checkout_rounded,
      Icons.add_shopping_cart_rounded,
      Icons.inventory_2_rounded,
      Icons.inventory_2_outlined,
      Icons.receipt_rounded,
      Icons.receipt_outlined,
      Icons.assignment_rounded,
      Icons.fact_check_rounded,
      Icons.pending_actions_rounded,
      Icons.delivery_dining_rounded,
      Icons.local_shipping_rounded,
    }.contains(icon)) {
      return iconCart;
    }

    if ({
      Icons.payments_rounded,
      Icons.payment_rounded,
      Icons.credit_card_rounded,
      Icons.attach_money_rounded,
      Icons.account_balance_wallet_rounded,
      Icons.monetization_on_rounded,
      Icons.receipt_long_rounded,
      Icons.add_card_rounded,
      Icons.price_check_rounded,
      Icons.request_quote_rounded,
      Icons.account_balance_rounded,
      Icons.money_rounded,
    }.contains(icon)) {
      return iconPayments;
    }

    if ({
      Icons.local_offer_rounded,
      Icons.local_offer_outlined,
      Icons.sell_rounded,
      Icons.percent_rounded,
      Icons.campaign_rounded,
      Icons.confirmation_number_rounded,
      Icons.confirmation_number_outlined,
      Icons.local_offer,
      Icons.discount_rounded,
      Icons.loyalty_rounded,
      Icons.card_giftcard_rounded,
      Icons.redeem_rounded,
    }.contains(icon)) {
      return iconPromotion;
    }

    if ({
      Icons.bar_chart_rounded,
      Icons.bar_chart,
      Icons.analytics_rounded,
      Icons.insights_rounded,
      Icons.query_stats_rounded,
      Icons.trending_up_rounded,
      Icons.pie_chart_rounded,
      Icons.show_chart_rounded,
      Icons.stacked_bar_chart_rounded,
      Icons.leaderboard_rounded,
      Icons.timeline_rounded,
    }.contains(icon)) {
      return iconStatistics;
    }

    if ({
      Icons.star_rounded,
      Icons.star_outline_rounded,
      Icons.star_border_rounded,
    }.contains(icon)) {
      return iconRating;
    }

    if ({
      Icons.verified_rounded,
      Icons.verified_user_rounded,
      Icons.check_circle_rounded,
      Icons.check_circle_outline_rounded,
      Icons.task_alt_rounded,
      Icons.workspace_premium_rounded,
      Icons.shield_rounded,
      Icons.shield_outlined,
      Icons.verified_user_outlined,
      Icons.verified,
      Icons.assignment_turned_in_rounded,
      Icons.done_rounded,
      Icons.done_all_rounded,
      Icons.check_rounded,
      Icons.how_to_reg_rounded,
    }.contains(icon)) {
      return iconValidation;
    }

    if ({
      Icons.location_on_rounded,
      Icons.location_on_outlined,
      Icons.map_rounded,
      Icons.map_outlined,
      Icons.place_rounded,
      Icons.my_location_rounded,
    }.contains(icon)) {
      return iconLocation;
    }

    if ({
      Icons.phone_rounded,
      Icons.phone_outlined,
      Icons.phone_iphone_rounded,
      Icons.email_rounded,
      Icons.email_outlined,
      Icons.chat_rounded,
      Icons.message_rounded,
      Icons.sms_rounded,
      Icons.video_call_rounded,
      Icons.video_call_outlined,
      Icons.videocam_rounded,
      Icons.mark_email_read_rounded,
      Icons.mark_email_unread_rounded,
      Icons.notifications_active_rounded,
      Icons.share_rounded,
      Icons.call_rounded,
      Icons.alternate_email_rounded,
      Icons.contact_phone_rounded,
    }.contains(icon)) {
      return iconCommunication;
    }

    if ({
      Icons.person_rounded,
      Icons.person_outline_rounded,
      Icons.people_rounded,
      Icons.people_alt_rounded,
      Icons.groups_rounded,
      Icons.groups_2_rounded,
      Icons.people,
      Icons.person,
      Icons.person_add_alt_1_rounded,
      Icons.person_search_rounded,
      Icons.manage_accounts_rounded,
      Icons.account_circle_rounded,
      Icons.badge_rounded,
      Icons.group_rounded,
      Icons.assignment_ind_rounded,
      Icons.person_pin_rounded,
    }.contains(icon)) {
      return iconProfile;
    }

    if ({
      Icons.grid_view_rounded,
      Icons.category_rounded,
      Icons.visibility_rounded,
      Icons.visibility_off_rounded,
      Icons.edit_rounded,
      Icons.edit_outlined,
      Icons.image_rounded,
      Icons.add_photo_alternate_rounded,
      Icons.camera_alt_rounded,
      Icons.public,
      Icons.public_rounded,
      Icons.language_rounded,
      Icons.notes_rounded,
      Icons.article_rounded,
      Icons.reviews_rounded,
      Icons.edit_note_rounded,
      Icons.flag_rounded,
      Icons.filter_list_rounded,
      Icons.tune_rounded,
      Icons.sort_rounded,
      Icons.search_rounded,
      Icons.menu_rounded,
      Icons.more_horiz_rounded,
      Icons.chevron_right_rounded,
      Icons.arrow_forward_ios_rounded,
      Icons.arrow_back_rounded,
      Icons.add_rounded,
      Icons.remove_rounded,
      Icons.refresh_rounded,
      Icons.sync_rounded,
      Icons.straighten_rounded,
      Icons.scale_rounded,
      Icons.monitor_weight_rounded,
      Icons.height_rounded,
      Icons.flag_outlined,
      Icons.flag_circle_rounded,
    }.contains(icon)) {
      return iconInfo;
    }

    if ({
      Icons.warning_rounded,
      Icons.warning_amber_rounded,
      Icons.error_outline_rounded,
      Icons.info_outline_rounded,
      Icons.tips_and_updates_rounded,
      Icons.report_problem_rounded,
      Icons.notification_important_rounded,
      Icons.priority_high_rounded,
    }.contains(icon)) {
      return iconWarning;
    }

    if ({
      Icons.delete_rounded,
      Icons.delete_outline_rounded,
      Icons.cancel_rounded,
      Icons.close_rounded,
      Icons.block_rounded,
      Icons.cancel_outlined,
    }.contains(icon)) {
      return iconDanger;
    }

    if ({
      Icons.lock_rounded,
      Icons.lock_outline_rounded,
      Icons.security_rounded,
      Icons.admin_panel_settings_rounded,
      Icons.key_rounded,
      Icons.lock_person_rounded,
      Icons.policy_rounded,
    }.contains(icon)) {
      return iconSecurity;
    }

    return fallback;
  }

  static const _defaultPalette = RolePalette(
    primary: brandPrimary,
    secondary: brandSecondary,
    accent: brandSecondary,
    background: brandBackground,
    surface: brandSurface,
    text: brandText,
    mutedText: brandMutedText,
    headerStart: brandPrimary,
    headerEnd: brandSecondary,
    shadow: Color(0x240F4C81),
  );

  static const client = _defaultPalette;
  static const entrepreneur = _defaultPalette;
  static const nutritionist = _defaultPalette;
  static const admin = _defaultPalette;
}









