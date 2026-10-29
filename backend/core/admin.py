from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from core.models import Company, User, Role, PasswordResetOTP


@admin.register(Company)
class CompanyAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug', 'plan', 'is_active', 'created_at')
    search_fields = ('name', 'slug', 'domain')
    list_filter = ('plan', 'is_active')


@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ('name', 'company', 'is_system', 'created_at')
    search_fields = ('name',)
    list_filter = ('is_system',)


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('email', 'full_name', 'company', 'role', 'is_platform_admin', 'is_staff', 'is_active')
    list_filter = ('is_platform_admin', 'is_staff', 'is_active', 'company')
    search_fields = ('email', 'full_name')
    ordering = ('email',)
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal Info', {'fields': ('full_name', 'avatar_url')}),
        ('Tenant & Role', {'fields': ('company', 'role')}),
        ('Permissions', {'fields': ('is_platform_admin', 'is_staff', 'is_superuser', 'is_active', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'full_name', 'company', 'role', 'password1', 'password2'),
        }),
    )


@admin.register(PasswordResetOTP)
class PasswordResetOTPAdmin(admin.ModelAdmin):
    list_display = ('user', 'otp_code', 'is_used', 'expires_at', 'created_at')
    search_fields = ('user__email', 'otp_code')
