# Auth Module Structure

## Purpose
Authentication and onboarding flows.

## Folders
- `pages/`: route-level screens.
- `helpers/`: pure utility functions and lightweight decision helpers.
- `services/`: flow/business logic that orchestrates repositories/controllers.
- `mappers/`: error/result transformation between layers.
- `widgets/login/`: login-only UI pieces.
- `widgets/register/`: registration-only UI pieces.
- `widgets/phone/`: phone auth and OTP UI pieces.
- `widgets/common/`: shared auth widgets.

## Naming Rules
- `*_helper.dart`: pure helpers, no side effects.
- `*_service.dart`: orchestration and side-effect use cases.
- `*_mapper.dart`: transformation from one structure/message to another.
- Keep flow-specific widgets inside their flow folder, not in `common/`.

