CREATE OR REPLACE FUNCTION public.fixed_admin_email()
RETURNS text
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$ SELECT 'uuxz272@gmail.com'::text $$;

REVOKE ALL ON FUNCTION public.fixed_admin_email() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.fixed_admin_email() TO service_role;

CREATE OR REPLACE FUNCTION public.ensure_fixed_admin(_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  account_email text;
BEGIN
  SELECT lower(email) INTO account_email FROM auth.users WHERE id = _user_id;
  IF account_email = public.fixed_admin_email() THEN
    INSERT INTO public.user_roles (user_id, role)
    VALUES (_user_id, 'admin')
    ON CONFLICT (user_id, role) DO NOTHING;

    INSERT INTO public.subscriptions (user_id, plan, status, expires_at)
    VALUES (_user_id, 'yearly', 'active', now() + interval '100 years')
    ON CONFLICT (user_id) DO UPDATE
      SET plan = 'yearly', status = 'active',
          expires_at = GREATEST(public.subscriptions.expires_at, EXCLUDED.expires_at);
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.ensure_fixed_admin(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.ensure_fixed_admin(uuid) TO service_role;

CREATE OR REPLACE FUNCTION public.ensure_fixed_admin_after_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF lower(NEW.email) = public.fixed_admin_email() THEN
    PERFORM public.ensure_fixed_admin(NEW.id);
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS ensure_fixed_admin_auth_user ON auth.users;
CREATE TRIGGER ensure_fixed_admin_auth_user
AFTER INSERT OR UPDATE OF email ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.ensure_fixed_admin_after_auth_user();

INSERT INTO public.activation_codes (code, plan, duration_days, max_uses, used_count, active, note)
VALUES ('UUXZ@272', 'yearly', 36500, 1000000, 0, true, 'Permanent owner recovery serial')
ON CONFLICT (code) DO UPDATE
SET plan = 'yearly', duration_days = 36500, max_uses = 1000000, active = true,
    note = 'Permanent owner recovery serial';