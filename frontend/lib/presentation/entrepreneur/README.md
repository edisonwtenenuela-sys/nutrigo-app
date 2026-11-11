# Entrepreneur Module Structure

## Purpose
Business profile, products, payments, promotions, and analytics.

## Promotions Widgets
- `widgets/promotion/`: promotion CRUD UI.
- `widgets/coupon/`: coupon-specific UI.
- `widgets/product/`: product selectors used by promotions.
- `widgets/shared/`: summary/header shared in promotions.

## Naming Rules
- Keep business concept boundaries explicit (promotion vs coupon).
- Use `shared/` only when used in multiple promotion contexts.

