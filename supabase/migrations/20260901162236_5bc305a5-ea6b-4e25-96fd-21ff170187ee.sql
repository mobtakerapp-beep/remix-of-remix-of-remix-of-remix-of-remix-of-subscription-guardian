REVOKE ALL ON FUNCTION public.bootstrap_account(uuid, text, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.bootstrap_account(uuid, text, text) TO service_role;

REVOKE ALL ON FUNCTION public.ensure_fixed_admin_after_auth_user() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.ensure_fixed_admin_after_auth_user() TO service_role;

REVOKE ALL ON FUNCTION public.ensure_fixed_admin_trg() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.ensure_fixed_admin_trg() TO service_role;

REVOKE ALL ON FUNCTION public.protect_fixed_admin_role() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.protect_fixed_admin_role() TO service_role;

REVOKE ALL ON FUNCTION public.is_fixed_admin(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_fixed_admin(uuid) TO service_role;

REVOKE ALL ON FUNCTION public.has_role(uuid, public.app_role) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.has_role(uuid, public.app_role) TO authenticated, service_role;