
-- schema_relational.sql for initial database setup OpenSlides
-- Code generated. DO NOT EDIT.
CREATE EXTENSION hstore;  -- included in standard postgres-installations, check for alpine

create or replace function check_not_null_for_relation_lists() returns trigger as $not_null_trigger$
-- usage with 3 parameters IN TRIGGER DEFINITION:
-- table_name of field to check, usually a field in a view
-- column_name of field to check
-- foreign_key field name of triggered table, that will be used to SELECT the values to check the not null.
DECLARE
    table_name TEXT;
    column_name TEXT;
    foreign_key TEXT;
    foreign_id INTEGER;
    counted INTEGER;
begin
    table_name = TG_ARGV[0];
    column_name = TG_ARGV[1];
    foreign_key = TG_ARGV[2];

    IF (TG_OP = 'INSERT') THEN
        foreign_id := hstore(NEW) -> foreign_key;
        IF (foreign_id is NOT NULL) THEN
            foreign_id = NULL; -- no need to ask DB
        END IF;
    ELSIF (TG_OP = 'UPDATE') THEN
        foreign_id := hstore(NEW) -> foreign_key;
        IF (foreign_id is NULL) THEN
            foreign_id = OLD.used_as_default_projector_for_topic_in_meeting_id;
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        foreign_id := hstore(OLD) -> foreign_key;
    END IF;

    IF (foreign_id IS NOT NULL) THEN
        EXECUTE format('SELECT array_length(%I, 1) FROM %I where id = %s', column_name, table_name, foreign_id) INTO counted;
        IF (counted is NULL) THEN
            RAISE EXCEPTION 'Trigger % Exception: NOT NULL CONSTRAINT VIOLATED for %.%', TG_NAME, table_name, column_name;
        END IF;
    END IF;
    RETURN NULL;  -- AFTER TRIGGER needs no return
end;
$not_null_trigger$ language plpgsql;

CREATE OR REPLACE FUNCTION truncate_tables(username IN VARCHAR) RETURNS void AS $$
DECLARE
    statements CURSOR FOR
        SELECT tablename FROM pg_tables
        WHERE tableowner = username AND schemaname = 'public';
BEGIN
    FOR stmt IN statements LOOP
        EXECUTE 'TRUNCATE TABLE ' || quote_ident(stmt.tablename) || ' RESTART IDENTITY CASCADE;';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- MODELS_YML_CHECKSUM = 'a0ab7cba150b1eeae6c16bb3e658496a'
-- Type definitions
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_organization_default_language') THEN
        CREATE TYPE enum_organization_default_language AS ENUM ('en', 'de', 'it', 'es', 'ru', 'cs', 'fr');
    ELSE
        RAISE NOTICE 'type "enum_organization_default_language" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_user_organization_management_level') THEN
        CREATE TYPE enum_user_organization_management_level AS ENUM ('superadmin', 'can_manage_organization', 'can_manage_users');
    ELSE
        RAISE NOTICE 'type "enum_user_organization_management_level" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_language') THEN
        CREATE TYPE enum_meeting_language AS ENUM ('en', 'de', 'it', 'es', 'ru', 'cs', 'fr');
    ELSE
        RAISE NOTICE 'type "enum_meeting_language" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_applause_type') THEN
        CREATE TYPE enum_meeting_applause_type AS ENUM ('applause-type-bar', 'applause-type-particles');
    ELSE
        RAISE NOTICE 'type "enum_meeting_applause_type" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_export_csv_encoding') THEN
        CREATE TYPE enum_meeting_export_csv_encoding AS ENUM ('utf-8', 'iso-8859-15');
    ELSE
        RAISE NOTICE 'type "enum_meeting_export_csv_encoding" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_export_pdf_pagenumber_alignment') THEN
        CREATE TYPE enum_meeting_export_pdf_pagenumber_alignment AS ENUM ('left', 'right', 'center');
    ELSE
        RAISE NOTICE 'type "enum_meeting_export_pdf_pagenumber_alignment" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_export_pdf_fontsize') THEN
        CREATE TYPE enum_meeting_export_pdf_fontsize AS ENUM ('10', '11', '12');
    ELSE
        RAISE NOTICE 'type "enum_meeting_export_pdf_fontsize" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_export_pdf_pagesize') THEN
        CREATE TYPE enum_meeting_export_pdf_pagesize AS ENUM ('A4', 'A5');
    ELSE
        RAISE NOTICE 'type "enum_meeting_export_pdf_pagesize" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_agenda_numeral_system') THEN
        CREATE TYPE enum_meeting_agenda_numeral_system AS ENUM ('arabic', 'roman');
    ELSE
        RAISE NOTICE 'type "enum_meeting_agenda_numeral_system" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_agenda_item_creation') THEN
        CREATE TYPE enum_meeting_agenda_item_creation AS ENUM ('always', 'never', 'default_yes', 'default_no');
    ELSE
        RAISE NOTICE 'type "enum_meeting_agenda_item_creation" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_agenda_new_items_default_visibility') THEN
        CREATE TYPE enum_meeting_agenda_new_items_default_visibility AS ENUM ('common', 'internal', 'hidden');
    ELSE
        RAISE NOTICE 'type "enum_meeting_agenda_new_items_default_visibility" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_motions_default_line_numbering') THEN
        CREATE TYPE enum_meeting_motions_default_line_numbering AS ENUM ('outside', 'inline', 'none');
    ELSE
        RAISE NOTICE 'type "enum_meeting_motions_default_line_numbering" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_motions_recommendation_text_mode') THEN
        CREATE TYPE enum_meeting_motions_recommendation_text_mode AS ENUM ('original', 'changed', 'diff', 'agreed');
    ELSE
        RAISE NOTICE 'type "enum_meeting_motions_recommendation_text_mode" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_motions_default_sorting') THEN
        CREATE TYPE enum_meeting_motions_default_sorting AS ENUM ('number', 'weight');
    ELSE
        RAISE NOTICE 'type "enum_meeting_motions_default_sorting" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_motions_number_type') THEN
        CREATE TYPE enum_meeting_motions_number_type AS ENUM ('per_category', 'serially_numbered', 'manually');
    ELSE
        RAISE NOTICE 'type "enum_meeting_motions_number_type" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_motions_amendments_text_mode') THEN
        CREATE TYPE enum_meeting_motions_amendments_text_mode AS ENUM ('freestyle', 'fulltext', 'paragraph');
    ELSE
        RAISE NOTICE 'type "enum_meeting_motions_amendments_text_mode" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_motion_poll_ballot_paper_selection') THEN
        CREATE TYPE enum_meeting_motion_poll_ballot_paper_selection AS ENUM ('NUMBER_OF_DELEGATES', 'NUMBER_OF_ALL_PARTICIPANTS', 'CUSTOM_NUMBER');
    ELSE
        RAISE NOTICE 'type "enum_meeting_motion_poll_ballot_paper_selection" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_motion_poll_default_onehundred_percent_base') THEN
        CREATE TYPE enum_meeting_motion_poll_default_onehundred_percent_base AS ENUM ('Y', 'YN', 'YNA', 'N', 'valid', 'cast', 'entitled', 'entitled_present', 'disabled');
    ELSE
        RAISE NOTICE 'type "enum_meeting_motion_poll_default_onehundred_percent_base" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_motion_poll_default_backend') THEN
        CREATE TYPE enum_meeting_motion_poll_default_backend AS ENUM ('long', 'fast');
    ELSE
        RAISE NOTICE 'type "enum_meeting_motion_poll_default_backend" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_users_pdf_wlan_encryption') THEN
        CREATE TYPE enum_meeting_users_pdf_wlan_encryption AS ENUM ('', 'WEP', 'WPA', 'nopass');
    ELSE
        RAISE NOTICE 'type "enum_meeting_users_pdf_wlan_encryption" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_assignment_poll_ballot_paper_selection') THEN
        CREATE TYPE enum_meeting_assignment_poll_ballot_paper_selection AS ENUM ('NUMBER_OF_DELEGATES', 'NUMBER_OF_ALL_PARTICIPANTS', 'CUSTOM_NUMBER');
    ELSE
        RAISE NOTICE 'type "enum_meeting_assignment_poll_ballot_paper_selection" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_assignment_poll_default_onehundred_percent_base') THEN
        CREATE TYPE enum_meeting_assignment_poll_default_onehundred_percent_base AS ENUM ('Y', 'YN', 'YNA', 'N', 'valid', 'cast', 'entitled', 'entitled_present', 'disabled');
    ELSE
        RAISE NOTICE 'type "enum_meeting_assignment_poll_default_onehundred_percent_base" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_assignment_poll_default_backend') THEN
        CREATE TYPE enum_meeting_assignment_poll_default_backend AS ENUM ('long', 'fast');
    ELSE
        RAISE NOTICE 'type "enum_meeting_assignment_poll_default_backend" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_poll_ballot_paper_selection') THEN
        CREATE TYPE enum_meeting_poll_ballot_paper_selection AS ENUM ('NUMBER_OF_DELEGATES', 'NUMBER_OF_ALL_PARTICIPANTS', 'CUSTOM_NUMBER');
    ELSE
        RAISE NOTICE 'type "enum_meeting_poll_ballot_paper_selection" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_poll_default_onehundred_percent_base') THEN
        CREATE TYPE enum_meeting_poll_default_onehundred_percent_base AS ENUM ('Y', 'YN', 'YNA', 'N', 'valid', 'cast', 'entitled', 'entitled_present', 'disabled');
    ELSE
        RAISE NOTICE 'type "enum_meeting_poll_default_onehundred_percent_base" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_meeting_poll_default_backend') THEN
        CREATE TYPE enum_meeting_poll_default_backend AS ENUM ('long', 'fast');
    ELSE
        RAISE NOTICE 'type "enum_meeting_poll_default_backend" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_group_permissions') THEN
        CREATE TYPE enum_group_permissions AS ENUM ('agenda_item.can_manage', 'agenda_item.can_see', 'agenda_item.can_see_internal', 'agenda_item.can_manage_moderator_notes', 'agenda_item.can_see_moderator_notes', 'assignment.can_manage', 'assignment.can_nominate_other', 'assignment.can_nominate_self', 'assignment.can_see', 'chat.can_manage', 'list_of_speakers.can_be_speaker', 'list_of_speakers.can_manage', 'list_of_speakers.can_see', 'mediafile.can_manage', 'mediafile.can_see', 'meeting.can_manage_logos_and_fonts', 'meeting.can_manage_settings', 'meeting.can_see_autopilot', 'meeting.can_see_frontpage', 'meeting.can_see_history', 'meeting.can_see_livestream', 'motion.can_create', 'motion.can_create_amendments', 'motion.can_forward', 'motion.can_manage', 'motion.can_manage_metadata', 'motion.can_manage_polls', 'motion.can_see', 'motion.can_see_internal', 'motion.can_support', 'poll.can_manage', 'projector.can_manage', 'projector.can_see', 'tag.can_manage', 'user.can_manage', 'user.can_manage_presence', 'user.can_see_sensitive_data', 'user.can_see', 'user.can_update');
    ELSE
        RAISE NOTICE 'type "enum_group_permissions" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_agenda_item_type') THEN
        CREATE TYPE enum_agenda_item_type AS ENUM ('common', 'internal', 'hidden');
    ELSE
        RAISE NOTICE 'type "enum_agenda_item_type" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_speaker_speech_state') THEN
        CREATE TYPE enum_speaker_speech_state AS ENUM ('contribution', 'pro', 'contra', 'intervention', 'interposed_question');
    ELSE
        RAISE NOTICE 'type "enum_speaker_speech_state" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_motion_change_recommendation_type') THEN
        CREATE TYPE enum_motion_change_recommendation_type AS ENUM ('replacement', 'insertion', 'deletion', 'other');
    ELSE
        RAISE NOTICE 'type "enum_motion_change_recommendation_type" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_motion_state_css_class') THEN
        CREATE TYPE enum_motion_state_css_class AS ENUM ('grey', 'red', 'green', 'lightblue', 'yellow');
    ELSE
        RAISE NOTICE 'type "enum_motion_state_css_class" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_motion_state_restrictions') THEN
        CREATE TYPE enum_motion_state_restrictions AS ENUM ('motion.can_see_internal', 'motion.can_manage_metadata', 'motion.can_manage', 'is_submitter');
    ELSE
        RAISE NOTICE 'type "enum_motion_state_restrictions" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_motion_state_merge_amendment_into_final') THEN
        CREATE TYPE enum_motion_state_merge_amendment_into_final AS ENUM ('do_not_merge', 'undefined', 'do_merge');
    ELSE
        RAISE NOTICE 'type "enum_motion_state_merge_amendment_into_final" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_poll_type') THEN
        CREATE TYPE enum_poll_type AS ENUM ('analog', 'named', 'pseudoanonymous', 'cryptographic');
    ELSE
        RAISE NOTICE 'type "enum_poll_type" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_poll_backend') THEN
        CREATE TYPE enum_poll_backend AS ENUM ('long', 'fast');
    ELSE
        RAISE NOTICE 'type "enum_poll_backend" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_poll_pollmethod') THEN
        CREATE TYPE enum_poll_pollmethod AS ENUM ('Y', 'YN', 'YNA', 'N');
    ELSE
        RAISE NOTICE 'type "enum_poll_pollmethod" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_poll_state') THEN
        CREATE TYPE enum_poll_state AS ENUM ('created', 'started', 'finished', 'published');
    ELSE
        RAISE NOTICE 'type "enum_poll_state" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_poll_onehundred_percent_base') THEN
        CREATE TYPE enum_poll_onehundred_percent_base AS ENUM ('Y', 'YN', 'YNA', 'N', 'valid', 'cast', 'entitled', 'entitled_present', 'disabled');
    ELSE
        RAISE NOTICE 'type "enum_poll_onehundred_percent_base" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_assignment_phase') THEN
        CREATE TYPE enum_assignment_phase AS ENUM ('search', 'voting', 'finished');
    ELSE
        RAISE NOTICE 'type "enum_assignment_phase" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_action_worker_state') THEN
        CREATE TYPE enum_action_worker_state AS ENUM ('running', 'end', 'aborted');
    ELSE
        RAISE NOTICE 'type "enum_action_worker_state" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_import_preview_name') THEN
        CREATE TYPE enum_import_preview_name AS ENUM ('account', 'participant', 'topic', 'committee', 'motion');
    ELSE
        RAISE NOTICE 'type "enum_import_preview_name" already exists, skipping';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_import_preview_state') THEN
        CREATE TYPE enum_import_preview_state AS ENUM ('warning', 'error', 'done');
    ELSE
        RAISE NOTICE 'type "enum_import_preview_state" already exists, skipping';
    END IF;
END$$;


-- Table definitions
CREATE TABLE IF NOT EXISTS organizationT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name varchar(256),
    description text,
    legal_notice text,
    privacy_policy text,
    login_text text,
    reset_password_verbose_errors boolean,
    genders varchar(256)[] DEFAULT '{"male", "female", "diverse", "non-binary"}',
    enable_electronic_voting boolean,
    enable_chat boolean,
    limit_of_meetings integer CONSTRAINT minimum_limit_of_meetings CHECK (limit_of_meetings >= 0) DEFAULT 0,
    limit_of_users integer CONSTRAINT minimum_limit_of_users CHECK (limit_of_users >= 0) DEFAULT 0,
    default_language enum_organization_default_language NOT NULL,
    saml_enabled boolean,
    saml_login_button_text varchar(256) DEFAULT 'SAML login',
    saml_attr_mapping jsonb,
    saml_metadata_idp text,
    saml_metadata_sp text,
    saml_private_key text,
    users_email_sender varchar(256) DEFAULT 'OpenSlides',
    users_email_replyto varchar(256),
    users_email_subject varchar(256) DEFAULT 'OpenSlides access data',
    users_email_body text DEFAULT 'Dear {name},

this is your personal OpenSlides login:

{url}
Username: {username}
Password: {password}


This email was generated automatically.',
    url varchar(256) DEFAULT 'https://example.com'
);



comment on column organizationT.limit_of_meetings is 'Maximum of active meetings for the whole organization. 0 means no limitation at all';
comment on column organizationT.limit_of_users is 'Maximum of active users for the whole organization. 0 means no limitation at all';

/*
 Fields without SQL definition for table organization

    vote_decrypt_public_main_key type:string is marked as a calculated field

*/

CREATE TABLE IF NOT EXISTS userT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    username varchar(256) NOT NULL,
    saml_id varchar(256) CONSTRAINT minlength_saml_id CHECK (char_length(saml_id) >= 1),
    pronoun varchar(32),
    title varchar(256),
    first_name varchar(256),
    last_name varchar(256),
    is_active boolean,
    is_physical_person boolean DEFAULT True,
    password varchar(256),
    default_password varchar(256),
    can_change_own_password boolean DEFAULT True,
    gender varchar(256),
    email varchar(256),
    default_vote_weight decimal(6) CONSTRAINT minimum_default_vote_weight CHECK (default_vote_weight >= 0.000001) DEFAULT '1.000000',
    last_email_sent timestamptz,
    is_demo_user boolean,
    last_login timestamptz,
    organization_management_level enum_user_organization_management_level,
    committee_ids integer[],
    meeting_ids integer[]
);



comment on column userT.saml_id is 'unique-key from IdP for SAML login';
comment on column userT.organization_management_level is 'Hierarchical permission level for the whole organization.';
comment on column userT.committee_ids is 'Calculated field: Returns committee_ids, where the user is manager or member in a meeting';
comment on column userT.meeting_ids is 'Calculated. All ids from meetings calculated via meeting_user and group_ids as integers.';


CREATE TABLE IF NOT EXISTS meeting_userT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    comment text,
    number varchar(256),
    about_me text,
    vote_weight decimal(6) CONSTRAINT minimum_vote_weight CHECK (vote_weight >= 0.000001),
    user_id integer NOT NULL,
    meeting_id integer NOT NULL,
    vote_delegated_to_id integer
);




CREATE TABLE IF NOT EXISTS organization_tagT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name varchar(256) NOT NULL,
    color integer CHECK (color >= 0 and color <= 16777215) NOT NULL
);




CREATE TABLE IF NOT EXISTS themeT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    name varchar(256) NOT NULL,
    accent_100 integer CHECK (accent_100 >= 0 and accent_100 <= 16777215),
    accent_200 integer CHECK (accent_200 >= 0 and accent_200 <= 16777215),
    accent_300 integer CHECK (accent_300 >= 0 and accent_300 <= 16777215),
    accent_400 integer CHECK (accent_400 >= 0 and accent_400 <= 16777215),
    accent_50 integer CHECK (accent_50 >= 0 and accent_50 <= 16777215),
    accent_500 integer CHECK (accent_500 >= 0 and accent_500 <= 16777215) NOT NULL,
    accent_600 integer CHECK (accent_600 >= 0 and accent_600 <= 16777215),
    accent_700 integer CHECK (accent_700 >= 0 and accent_700 <= 16777215),
    accent_800 integer CHECK (accent_800 >= 0 and accent_800 <= 16777215),
    accent_900 integer CHECK (accent_900 >= 0 and accent_900 <= 16777215),
    accent_a100 integer CHECK (accent_a100 >= 0 and accent_a100 <= 16777215),
    accent_a200 integer CHECK (accent_a200 >= 0 and accent_a200 <= 16777215),
    accent_a400 integer CHECK (accent_a400 >= 0 and accent_a400 <= 16777215),
    accent_a700 integer CHECK (accent_a700 >= 0 and accent_a700 <= 16777215),
    primary_100 integer CHECK (primary_100 >= 0 and primary_100 <= 16777215),
    primary_200 integer CHECK (primary_200 >= 0 and primary_200 <= 16777215),
    primary_300 integer CHECK (primary_300 >= 0 and primary_300 <= 16777215),
    primary_400 integer CHECK (primary_400 >= 0 and primary_400 <= 16777215),
    primary_50 integer CHECK (primary_50 >= 0 and primary_50 <= 16777215),
    primary_500 integer CHECK (primary_500 >= 0 and primary_500 <= 16777215) NOT NULL,
    primary_600 integer CHECK (primary_600 >= 0 and primary_600 <= 16777215),
    primary_700 integer CHECK (primary_700 >= 0 and primary_700 <= 16777215),
    primary_800 integer CHECK (primary_800 >= 0 and primary_800 <= 16777215),
    primary_900 integer CHECK (primary_900 >= 0 and primary_900 <= 16777215),
    primary_a100 integer CHECK (primary_a100 >= 0 and primary_a100 <= 16777215),
    primary_a200 integer CHECK (primary_a200 >= 0 and primary_a200 <= 16777215),
    primary_a400 integer CHECK (primary_a400 >= 0 and primary_a400 <= 16777215),
    primary_a700 integer CHECK (primary_a700 >= 0 and primary_a700 <= 16777215),
    warn_100 integer CHECK (warn_100 >= 0 and warn_100 <= 16777215),
    warn_200 integer CHECK (warn_200 >= 0 and warn_200 <= 16777215),
    warn_300 integer CHECK (warn_300 >= 0 and warn_300 <= 16777215),
    warn_400 integer CHECK (warn_400 >= 0 and warn_400 <= 16777215),
    warn_50 integer CHECK (warn_50 >= 0 and warn_50 <= 16777215),
    warn_500 integer CHECK (warn_500 >= 0 and warn_500 <= 16777215) NOT NULL,
    warn_600 integer CHECK (warn_600 >= 0 and warn_600 <= 16777215),
    warn_700 integer CHECK (warn_700 >= 0 and warn_700 <= 16777215),
    warn_800 integer CHECK (warn_800 >= 0 and warn_800 <= 16777215),
    warn_900 integer CHECK (warn_900 >= 0 and warn_900 <= 16777215),
    warn_a100 integer CHECK (warn_a100 >= 0 and warn_a100 <= 16777215),
    warn_a200 integer CHECK (warn_a200 >= 0 and warn_a200 <= 16777215),
    warn_a400 integer CHECK (warn_a400 >= 0 and warn_a400 <= 16777215),
    warn_a700 integer CHECK (warn_a700 >= 0 and warn_a700 <= 16777215),
    headbar integer CHECK (headbar >= 0 and headbar <= 16777215),
    yes integer CHECK (yes >= 0 and yes <= 16777215),
    no integer CHECK (no >= 0 and no <= 16777215),
    abstain integer CHECK (abstain >= 0 and abstain <= 16777215)
);




CREATE TABLE IF NOT EXISTS committeeT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name varchar(256) NOT NULL,
    description text,
    external_id varchar(256),
    user_ids integer[],
    forwarding_user_id integer
);



comment on column committeeT.external_id is 'unique';
comment on column committeeT.user_ids is 'Calculated field: All users which are in a group of a meeting, belonging to the committee or beeing manager of the committee';


CREATE TABLE IF NOT EXISTS meetingT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    external_id varchar(256),
    welcome_title varchar(256) DEFAULT 'Welcome to OpenSlides',
    welcome_text text DEFAULT 'Space for your welcome text.',
    name varchar(100) NOT NULL DEFAULT 'OpenSlides',
    is_active_in_organization_id integer,
    is_archived_in_organization_id integer,
    description varchar(100) DEFAULT 'Presentation and assembly system',
    location varchar(256),
    start_time timestamptz,
    end_time timestamptz,
    imported_at timestamptz,
    language enum_meeting_language NOT NULL,
    jitsi_domain varchar(256),
    jitsi_room_name varchar(256),
    jitsi_room_password varchar(256),
    template_for_organization_id integer,
    enable_anonymous boolean DEFAULT False,
    custom_translations jsonb,
    conference_show boolean DEFAULT False,
    conference_auto_connect boolean DEFAULT False,
    conference_los_restriction boolean DEFAULT True,
    conference_stream_url varchar(256),
    conference_stream_poster_url varchar(256),
    conference_open_microphone boolean DEFAULT False,
    conference_open_video boolean DEFAULT False,
    conference_auto_connect_next_speakers integer DEFAULT 0,
    conference_enable_helpdesk boolean DEFAULT False,
    applause_enable boolean DEFAULT False,
    applause_type enum_meeting_applause_type DEFAULT 'applause-type-bar',
    applause_show_level boolean DEFAULT False,
    applause_min_amount integer CONSTRAINT minimum_applause_min_amount CHECK (applause_min_amount >= 0) DEFAULT 1,
    applause_max_amount integer CONSTRAINT minimum_applause_max_amount CHECK (applause_max_amount >= 0) DEFAULT 0,
    applause_timeout integer CONSTRAINT minimum_applause_timeout CHECK (applause_timeout >= 0) DEFAULT 5,
    applause_particle_image_url varchar(256),
    projector_countdown_default_time integer NOT NULL DEFAULT 60,
    projector_countdown_warning_time integer NOT NULL CONSTRAINT minimum_projector_countdown_warning_time CHECK (projector_countdown_warning_time >= 0) DEFAULT 0,
    export_csv_encoding enum_meeting_export_csv_encoding DEFAULT 'utf-8',
    export_csv_separator varchar(256) DEFAULT ';',
    export_pdf_pagenumber_alignment enum_meeting_export_pdf_pagenumber_alignment DEFAULT 'center',
    export_pdf_fontsize enum_meeting_export_pdf_fontsize DEFAULT '10',
    export_pdf_line_height real CONSTRAINT minimum_export_pdf_line_height CHECK (export_pdf_line_height >= 1.0) DEFAULT 1.25,
    export_pdf_page_margin_left integer CONSTRAINT minimum_export_pdf_page_margin_left CHECK (export_pdf_page_margin_left >= 0) DEFAULT 20,
    export_pdf_page_margin_top integer CONSTRAINT minimum_export_pdf_page_margin_top CHECK (export_pdf_page_margin_top >= 0) DEFAULT 25,
    export_pdf_page_margin_right integer CONSTRAINT minimum_export_pdf_page_margin_right CHECK (export_pdf_page_margin_right >= 0) DEFAULT 20,
    export_pdf_page_margin_bottom integer CONSTRAINT minimum_export_pdf_page_margin_bottom CHECK (export_pdf_page_margin_bottom >= 0) DEFAULT 20,
    export_pdf_pagesize enum_meeting_export_pdf_pagesize DEFAULT 'A4',
    agenda_show_subtitles boolean DEFAULT False,
    agenda_enable_numbering boolean DEFAULT True,
    agenda_number_prefix varchar(20),
    agenda_numeral_system enum_meeting_agenda_numeral_system DEFAULT 'arabic',
    agenda_item_creation enum_meeting_agenda_item_creation DEFAULT 'default_no',
    agenda_new_items_default_visibility enum_meeting_agenda_new_items_default_visibility DEFAULT 'internal',
    agenda_show_internal_items_on_projector boolean DEFAULT False,
    list_of_speakers_amount_last_on_projector integer CONSTRAINT minimum_list_of_speakers_amount_last_on_projector CHECK (list_of_speakers_amount_last_on_projector >= -1) DEFAULT 0,
    list_of_speakers_amount_next_on_projector integer CONSTRAINT minimum_list_of_speakers_amount_next_on_projector CHECK (list_of_speakers_amount_next_on_projector >= -1) DEFAULT -1,
    list_of_speakers_couple_countdown boolean DEFAULT True,
    list_of_speakers_show_amount_of_speakers_on_slide boolean DEFAULT True,
    list_of_speakers_present_users_only boolean DEFAULT False,
    list_of_speakers_show_first_contribution boolean DEFAULT False,
    list_of_speakers_hide_contribution_count boolean DEFAULT False,
    list_of_speakers_allow_multiple_speakers boolean DEFAULT False,
    list_of_speakers_enable_point_of_order_speakers boolean DEFAULT True,
    list_of_speakers_can_create_point_of_order_for_others boolean DEFAULT False,
    list_of_speakers_enable_point_of_order_categories boolean DEFAULT False,
    list_of_speakers_closing_disables_point_of_order boolean DEFAULT False,
    list_of_speakers_enable_pro_contra_speech boolean DEFAULT False,
    list_of_speakers_can_set_contribution_self boolean DEFAULT False,
    list_of_speakers_speaker_note_for_everyone boolean DEFAULT True,
    list_of_speakers_initially_closed boolean DEFAULT False,
    list_of_speakers_default_structure_level_time integer CONSTRAINT minimum_list_of_speakers_default_structure_level_time CHECK (list_of_speakers_default_structure_level_time >= 0),
    list_of_speakers_enable_interposed_question boolean,
    list_of_speakers_intervention_time integer,
    motions_default_workflow_id integer NOT NULL,
    motions_default_amendment_workflow_id integer NOT NULL,
    motions_default_statute_amendment_workflow_id integer NOT NULL,
    motions_preamble text DEFAULT 'The assembly may decide:',
    motions_default_line_numbering enum_meeting_motions_default_line_numbering DEFAULT 'outside',
    motions_line_length integer CONSTRAINT minimum_motions_line_length CHECK (motions_line_length >= 40) DEFAULT 85,
    motions_reason_required boolean DEFAULT False,
    motions_enable_text_on_projector boolean DEFAULT True,
    motions_enable_reason_on_projector boolean DEFAULT False,
    motions_enable_sidebox_on_projector boolean DEFAULT False,
    motions_enable_recommendation_on_projector boolean DEFAULT True,
    motions_show_referring_motions boolean DEFAULT True,
    motions_show_sequential_number boolean DEFAULT True,
    motions_recommendations_by varchar(256),
    motions_block_slide_columns integer CONSTRAINT minimum_motions_block_slide_columns CHECK (motions_block_slide_columns >= 1),
    motions_statute_recommendations_by varchar(256),
    motions_recommendation_text_mode enum_meeting_motions_recommendation_text_mode DEFAULT 'diff',
    motions_default_sorting enum_meeting_motions_default_sorting DEFAULT 'number',
    motions_number_type enum_meeting_motions_number_type DEFAULT 'per_category',
    motions_number_min_digits integer DEFAULT 2,
    motions_number_with_blank boolean DEFAULT False,
    motions_statutes_enabled boolean DEFAULT False,
    motions_amendments_enabled boolean DEFAULT True,
    motions_amendments_in_main_list boolean DEFAULT True,
    motions_amendments_of_amendments boolean DEFAULT False,
    motions_amendments_prefix varchar(256) DEFAULT '-Ä',
    motions_amendments_text_mode enum_meeting_motions_amendments_text_mode DEFAULT 'paragraph',
    motions_amendments_multiple_paragraphs boolean DEFAULT True,
    motions_supporters_min_amount integer CONSTRAINT minimum_motions_supporters_min_amount CHECK (motions_supporters_min_amount >= 0) DEFAULT 0,
    motions_enable_editor boolean,
    motions_enable_working_group_speaker boolean,
    motions_export_title varchar(256) DEFAULT 'Motions',
    motions_export_preamble text,
    motions_export_submitter_recommendation boolean DEFAULT True,
    motions_export_follow_recommendation boolean DEFAULT False,
    motion_poll_ballot_paper_selection enum_meeting_motion_poll_ballot_paper_selection DEFAULT 'CUSTOM_NUMBER',
    motion_poll_ballot_paper_number integer DEFAULT 8,
    motion_poll_default_type varchar(256) DEFAULT 'pseudoanonymous',
    motion_poll_default_onehundred_percent_base enum_meeting_motion_poll_default_onehundred_percent_base DEFAULT 'YNA',
    motion_poll_default_backend enum_meeting_motion_poll_default_backend DEFAULT 'fast',
    users_enable_presence_view boolean DEFAULT False,
    users_enable_vote_weight boolean DEFAULT False,
    users_allow_self_set_present boolean DEFAULT True,
    users_pdf_welcometitle varchar(256) DEFAULT 'Welcome to OpenSlides',
    users_pdf_welcometext text DEFAULT '[Place for your welcome and help text.]',
    users_pdf_wlan_ssid varchar(256),
    users_pdf_wlan_password varchar(256),
    users_pdf_wlan_encryption enum_meeting_users_pdf_wlan_encryption DEFAULT 'WPA',
    users_email_sender varchar(256) DEFAULT 'OpenSlides',
    users_email_replyto varchar(256),
    users_email_subject varchar(256) DEFAULT 'OpenSlides access data',
    users_email_body text DEFAULT 'Dear {name},

this is your personal OpenSlides login:

{url}
Username: {username}
Password: {password}


This email was generated automatically.',
    users_enable_vote_delegations boolean,
    assignments_export_title varchar(256) DEFAULT 'Elections',
    assignments_export_preamble text,
    assignment_poll_ballot_paper_selection enum_meeting_assignment_poll_ballot_paper_selection DEFAULT 'CUSTOM_NUMBER',
    assignment_poll_ballot_paper_number integer DEFAULT 8,
    assignment_poll_add_candidates_to_list_of_speakers boolean DEFAULT False,
    assignment_poll_enable_max_votes_per_option boolean DEFAULT False,
    assignment_poll_sort_poll_result_by_votes boolean DEFAULT True,
    assignment_poll_default_type varchar(256) DEFAULT 'pseudoanonymous',
    assignment_poll_default_method varchar(256) DEFAULT 'Y',
    assignment_poll_default_onehundred_percent_base enum_meeting_assignment_poll_default_onehundred_percent_base DEFAULT 'valid',
    assignment_poll_default_backend enum_meeting_assignment_poll_default_backend DEFAULT 'fast',
    poll_ballot_paper_selection enum_meeting_poll_ballot_paper_selection,
    poll_ballot_paper_number integer,
    poll_sort_poll_result_by_votes boolean,
    poll_default_type varchar(256) DEFAULT 'analog',
    poll_default_method varchar(256),
    poll_default_onehundred_percent_base enum_meeting_poll_default_onehundred_percent_base DEFAULT 'YNA',
    poll_default_backend enum_meeting_poll_default_backend DEFAULT 'fast',
    poll_couple_countdown boolean DEFAULT True,
    committee_id integer NOT NULL,
    user_ids integer[],
    reference_projector_id integer NOT NULL,
    default_group_id integer NOT NULL
);



comment on column meetingT.external_id is 'unique in committee';
comment on column meetingT.is_active_in_organization_id is 'Backrelation and boolean flag at once';
comment on column meetingT.is_archived_in_organization_id is 'Backrelation and boolean flag at once';
comment on column meetingT.list_of_speakers_default_structure_level_time is '0 disables structure level countdowns.';
comment on column meetingT.list_of_speakers_intervention_time is '0 disables intervention speakers.';
comment on column meetingT.user_ids is 'Calculated. All user ids from all users assigned to groups of this meeting.';


CREATE TABLE IF NOT EXISTS structure_levelT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    name varchar(256) NOT NULL,
    color integer CHECK (color >= 0 and color <= 16777215),
    default_time integer CONSTRAINT minimum_default_time CHECK (default_time >= 0),
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS groupT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    external_id varchar(256),
    name varchar(256) NOT NULL,
    permissions enum_group_permissions[],
    weight integer,
    used_as_motion_poll_default_id integer,
    used_as_assignment_poll_default_id integer,
    used_as_topic_poll_default_id integer,
    used_as_poll_default_id integer,
    meeting_id integer NOT NULL
);



comment on column groupT.external_id is 'unique in meeting';


CREATE TABLE IF NOT EXISTS personal_noteT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    note text,
    star boolean,
    meeting_user_id integer NOT NULL,
    content_object_id varchar(100),
    content_object_id_motion_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'motion' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    CONSTRAINT valid_content_object_id_part1 CHECK (split_part(content_object_id, '/', 1) IN ('motion')),
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS tagT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name varchar(256) NOT NULL,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS agenda_itemT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    item_number varchar(256),
    comment varchar(256),
    closed boolean DEFAULT False,
    type enum_agenda_item_type DEFAULT 'common',
    duration integer CONSTRAINT minimum_duration CHECK (duration >= 0),
    moderator_notes text,
    is_internal boolean,
    is_hidden boolean,
    level integer,
    weight integer,
    content_object_id varchar(100) NOT NULL,
    content_object_id_motion_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'motion' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_motion_block_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'motion_block' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_assignment_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'assignment' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_topic_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'topic' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    CONSTRAINT valid_content_object_id_part1 CHECK (split_part(content_object_id, '/', 1) IN ('motion','motion_block','assignment','topic')),
    parent_id integer,
    meeting_id integer NOT NULL
);



comment on column agenda_itemT.duration is 'Given in seconds';
comment on column agenda_itemT.is_internal is 'Calculated by the server';
comment on column agenda_itemT.is_hidden is 'Calculated by the server';
comment on column agenda_itemT.level is 'Calculated by the server';


CREATE TABLE IF NOT EXISTS list_of_speakersT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    closed boolean DEFAULT False,
    sequential_number integer NOT NULL,
    content_object_id varchar(100) NOT NULL,
    content_object_id_motion_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'motion' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_motion_block_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'motion_block' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_assignment_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'assignment' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_topic_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'topic' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_mediafile_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'mediafile' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    CONSTRAINT valid_content_object_id_part1 CHECK (split_part(content_object_id, '/', 1) IN ('motion','motion_block','assignment','topic','mediafile')),
    meeting_id integer NOT NULL
);



comment on column list_of_speakersT.sequential_number is 'The (positive) serial number of this model in its meeting. This number is auto-generated and read-only.';


CREATE TABLE IF NOT EXISTS structure_level_list_of_speakersT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    structure_level_id integer NOT NULL,
    list_of_speakers_id integer NOT NULL,
    initial_time integer NOT NULL CONSTRAINT minimum_initial_time CHECK (initial_time >= 1),
    additional_time real,
    remaining_time real NOT NULL,
    current_start_time timestamptz,
    meeting_id integer NOT NULL
);



comment on column structure_level_list_of_speakersT.initial_time is 'The initial time of this structure_level for this LoS';
comment on column structure_level_list_of_speakersT.additional_time is 'The summed added time of this structure_level for this LoS';
comment on column structure_level_list_of_speakersT.remaining_time is 'The currently remaining time of this structure_level for this LoS';
comment on column structure_level_list_of_speakersT.current_start_time is 'The current start time of a speaker for this structure_level. Is only set if a currently speaking speaker exists';


CREATE TABLE IF NOT EXISTS point_of_order_categoryT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    text varchar(256) NOT NULL,
    rank integer NOT NULL,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS speakerT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    begin_time timestamptz,
    end_time timestamptz,
    pause_time timestamptz,
    unpause_time timestamptz,
    total_pause integer,
    weight integer DEFAULT 10000,
    speech_state enum_speaker_speech_state,
    note varchar(250),
    point_of_order boolean,
    list_of_speakers_id integer NOT NULL,
    structure_level_list_of_speakers_id integer,
    meeting_user_id integer,
    point_of_order_category_id integer,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS topicT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    title varchar(256) NOT NULL,
    text text,
    sequential_number integer NOT NULL,
    meeting_id integer NOT NULL
);



comment on column topicT.sequential_number is 'The (positive) serial number of this model in its meeting. This number is auto-generated and read-only.';


CREATE TABLE IF NOT EXISTS motionT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    number varchar(256),
    number_value integer,
    sequential_number integer NOT NULL,
    title varchar(256) NOT NULL,
    text text,
    text_hash varchar(256),
    amendment_paragraphs jsonb,
    modified_final_version text,
    reason text,
    category_weight integer DEFAULT 10000,
    state_extension varchar(256),
    recommendation_extension varchar(256),
    sort_weight integer DEFAULT 10000,
    created timestamptz,
    last_modified timestamptz,
    workflow_timestamp timestamptz,
    start_line_number integer CONSTRAINT minimum_start_line_number CHECK (start_line_number >= 1) DEFAULT 1,
    forwarded timestamptz,
    additional_submitter varchar(256),
    lead_motion_id integer,
    sort_parent_id integer,
    origin_id integer,
    origin_meeting_id integer,
    state_id integer NOT NULL,
    recommendation_id integer,
    category_id integer,
    block_id integer,
    statute_paragraph_id integer,
    meeting_id integer NOT NULL
);



comment on column motionT.number_value is 'The number value of this motion. This number is auto-generated and read-only.';
comment on column motionT.sequential_number is 'The (positive) serial number of this model in its meeting. This number is auto-generated and read-only.';

/*
 Fields without SQL definition for table motion

    identical_motion_ids type:dummy[] Unknown Type

*/

CREATE TABLE IF NOT EXISTS motion_submitterT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    weight integer,
    meeting_user_id integer NOT NULL,
    motion_id integer NOT NULL,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS motion_editorT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    weight integer,
    meeting_user_id integer NOT NULL,
    motion_id integer NOT NULL,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS motion_working_group_speakerT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    weight integer,
    meeting_user_id integer NOT NULL,
    motion_id integer NOT NULL,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS motion_commentT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    comment text,
    motion_id integer NOT NULL,
    section_id integer NOT NULL,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS motion_comment_sectionT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name varchar(256) NOT NULL,
    weight integer DEFAULT 10000,
    sequential_number integer NOT NULL,
    submitter_can_write boolean,
    meeting_id integer NOT NULL
);



comment on column motion_comment_sectionT.sequential_number is 'The (positive) serial number of this model in its meeting. This number is auto-generated and read-only.';


CREATE TABLE IF NOT EXISTS motion_categoryT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name varchar(256) NOT NULL,
    prefix varchar(256),
    weight integer DEFAULT 10000,
    level integer,
    sequential_number integer NOT NULL,
    parent_id integer,
    meeting_id integer NOT NULL
);



comment on column motion_categoryT.level is 'Calculated field.';
comment on column motion_categoryT.sequential_number is 'The (positive) serial number of this model in its meeting. This number is auto-generated and read-only.';


CREATE TABLE IF NOT EXISTS motion_blockT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    title varchar(256) NOT NULL,
    internal boolean,
    sequential_number integer NOT NULL,
    meeting_id integer NOT NULL
);



comment on column motion_blockT.sequential_number is 'The (positive) serial number of this model in its meeting. This number is auto-generated and read-only.';


CREATE TABLE IF NOT EXISTS motion_change_recommendationT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    rejected boolean DEFAULT False,
    internal boolean DEFAULT False,
    type enum_motion_change_recommendation_type DEFAULT 'replacement',
    other_description varchar(256),
    line_from integer CONSTRAINT minimum_line_from CHECK (line_from >= 0),
    line_to integer CONSTRAINT minimum_line_to CHECK (line_to >= 0),
    text text,
    creation_time timestamptz,
    motion_id integer NOT NULL,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS motion_stateT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name varchar(256) NOT NULL,
    weight integer NOT NULL,
    recommendation_label varchar(256),
    is_internal boolean,
    css_class enum_motion_state_css_class NOT NULL DEFAULT 'lightblue',
    restrictions enum_motion_state_restrictions[] DEFAULT '{}',
    allow_support boolean DEFAULT False,
    allow_create_poll boolean DEFAULT False,
    allow_submitter_edit boolean DEFAULT False,
    set_number boolean DEFAULT True,
    show_state_extension_field boolean DEFAULT False,
    show_recommendation_extension_field boolean DEFAULT False,
    merge_amendment_into_final enum_motion_state_merge_amendment_into_final DEFAULT 'undefined',
    allow_motion_forwarding boolean DEFAULT False,
    set_workflow_timestamp boolean DEFAULT False,
    submitter_withdraw_state_id integer,
    workflow_id integer NOT NULL,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS motion_workflowT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name varchar(256) NOT NULL,
    sequential_number integer NOT NULL,
    first_state_id integer NOT NULL,
    meeting_id integer NOT NULL
);



comment on column motion_workflowT.sequential_number is 'The (positive) serial number of this model in its meeting. This number is auto-generated and read-only.';


CREATE TABLE IF NOT EXISTS motion_statute_paragraphT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    title varchar(256) NOT NULL,
    text text,
    weight integer DEFAULT 10000,
    sequential_number integer NOT NULL,
    meeting_id integer NOT NULL
);



comment on column motion_statute_paragraphT.sequential_number is 'The (positive) serial number of this model in its meeting. This number is auto-generated and read-only.';


CREATE TABLE IF NOT EXISTS pollT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    description text,
    title varchar(256) NOT NULL,
    type enum_poll_type NOT NULL,
    backend enum_poll_backend NOT NULL DEFAULT 'fast',
    is_pseudoanonymized boolean,
    pollmethod enum_poll_pollmethod NOT NULL,
    state enum_poll_state DEFAULT 'created',
    min_votes_amount integer CONSTRAINT minimum_min_votes_amount CHECK (min_votes_amount >= 1) DEFAULT 1,
    max_votes_amount integer CONSTRAINT minimum_max_votes_amount CHECK (max_votes_amount >= 1) DEFAULT 1,
    max_votes_per_option integer CONSTRAINT minimum_max_votes_per_option CHECK (max_votes_per_option >= 1) DEFAULT 1,
    global_yes boolean DEFAULT False,
    global_no boolean DEFAULT False,
    global_abstain boolean DEFAULT False,
    onehundred_percent_base enum_poll_onehundred_percent_base NOT NULL DEFAULT 'disabled',
    votesvalid decimal(6),
    votesinvalid decimal(6),
    votescast decimal(6),
    entitled_users_at_stop jsonb,
    sequential_number integer NOT NULL,
    crypt_key varchar(256),
    crypt_signature varchar(256),
    votes_raw text,
    votes_signature varchar(256),
    content_object_id varchar(100) NOT NULL,
    content_object_id_motion_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'motion' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_assignment_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'assignment' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_topic_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'topic' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    CONSTRAINT valid_content_object_id_part1 CHECK (split_part(content_object_id, '/', 1) IN ('motion','assignment','topic')),
    meeting_id integer NOT NULL
);



comment on column pollT.sequential_number is 'The (positive) serial number of this model in its meeting. This number is auto-generated and read-only.';
comment on column pollT.crypt_key is 'base64 public key to cryptographic votes.';
comment on column pollT.crypt_signature is 'base64 signature of cryptographic_key.';
comment on column pollT.votes_raw is 'original form of decrypted votes.';
comment on column pollT.votes_signature is 'base64 signature of votes_raw field.';

/*
 Fields without SQL definition for table poll

    vote_count type:number is marked as a calculated field

*/

CREATE TABLE IF NOT EXISTS optionT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    weight integer DEFAULT 10000,
    text text,
    yes decimal(6),
    no decimal(6),
    abstain decimal(6),
    poll_id integer,
    content_object_id varchar(100),
    content_object_id_motion_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'motion' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_user_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'user' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_poll_candidate_list_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'poll_candidate_list' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    CONSTRAINT valid_content_object_id_part1 CHECK (split_part(content_object_id, '/', 1) IN ('motion','user','poll_candidate_list')),
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS voteT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    weight decimal(6),
    value varchar(256),
    user_token varchar(256) NOT NULL,
    option_id integer NOT NULL,
    user_id integer,
    delegated_user_id integer,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS assignmentT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    title varchar(256) NOT NULL,
    description text,
    open_posts integer CONSTRAINT minimum_open_posts CHECK (open_posts >= 0) DEFAULT 0,
    phase enum_assignment_phase DEFAULT 'search',
    default_poll_description text,
    number_poll_candidates boolean,
    sequential_number integer NOT NULL,
    meeting_id integer NOT NULL
);



comment on column assignmentT.sequential_number is 'The (positive) serial number of this model in its meeting. This number is auto-generated and read-only.';


CREATE TABLE IF NOT EXISTS assignment_candidateT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    weight integer DEFAULT 10000,
    assignment_id integer NOT NULL,
    meeting_user_id integer,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS poll_candidate_listT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS poll_candidateT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    poll_candidate_list_id integer NOT NULL,
    user_id integer,
    weight integer NOT NULL,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS mediafileT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    title varchar(256),
    is_directory boolean,
    filesize integer,
    filename varchar(256),
    mimetype varchar(256),
    pdf_information jsonb,
    create_timestamp timestamptz,
    is_public boolean NOT NULL,
    token varchar(256),
    parent_id integer,
    owner_id varchar(100) NOT NULL,
    owner_id_meeting_id integer GENERATED ALWAYS AS (CASE WHEN split_part(owner_id, '/', 1) = 'meeting' THEN cast(split_part(owner_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    owner_id_organization_id integer GENERATED ALWAYS AS (CASE WHEN split_part(owner_id, '/', 1) = 'organization' THEN cast(split_part(owner_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    CONSTRAINT valid_owner_id_part1 CHECK (split_part(owner_id, '/', 1) IN ('meeting','organization'))
);



comment on column mediafileT.title is 'Title and parent_id must be unique.';
comment on column mediafileT.filesize is 'In bytes, not the human readable format anymore.';
comment on column mediafileT.filename is 'The uploaded filename. Will be used for downloading. Only writeable on create.';
comment on column mediafileT.is_public is 'Calculated field. inherited_access_group_ids == [] can have two causes: cancelling access groups (=> is_public := false) or no access groups at all (=> is_public := true)';


CREATE TABLE IF NOT EXISTS projectorT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name varchar(256),
    is_internal boolean DEFAULT False,
    scale integer DEFAULT 0,
    scroll integer CONSTRAINT minimum_scroll CHECK (scroll >= 0) DEFAULT 0,
    width integer CONSTRAINT minimum_width CHECK (width >= 1) DEFAULT 1200,
    aspect_ratio_numerator integer CONSTRAINT minimum_aspect_ratio_numerator CHECK (aspect_ratio_numerator >= 1) DEFAULT 16,
    aspect_ratio_denominator integer CONSTRAINT minimum_aspect_ratio_denominator CHECK (aspect_ratio_denominator >= 1) DEFAULT 9,
    color integer CHECK (color >= 0 and color <= 16777215) DEFAULT 0,
    background_color integer CHECK (background_color >= 0 and background_color <= 16777215) DEFAULT 16777215,
    header_background_color integer CHECK (header_background_color >= 0 and header_background_color <= 16777215) DEFAULT 3241878,
    header_font_color integer CHECK (header_font_color >= 0 and header_font_color <= 16777215) DEFAULT 16119285,
    header_h1_color integer CHECK (header_h1_color >= 0 and header_h1_color <= 16777215) DEFAULT 3241878,
    chyron_background_color integer CHECK (chyron_background_color >= 0 and chyron_background_color <= 16777215) DEFAULT 3241878,
    chyron_font_color integer CHECK (chyron_font_color >= 0 and chyron_font_color <= 16777215) DEFAULT 16777215,
    show_header_footer boolean DEFAULT True,
    show_title boolean DEFAULT True,
    show_logo boolean DEFAULT True,
    show_clock boolean DEFAULT True,
    sequential_number integer NOT NULL,
    used_as_default_projector_for_agenda_item_list_in_meeting_id integer,
    used_as_default_projector_for_topic_in_meeting_id integer,
    used_as_default_projector_for_list_of_speakers_in_meeting_id integer,
    used_as_default_projector_for_current_los_in_meeting_id integer,
    used_as_default_projector_for_motion_in_meeting_id integer,
    used_as_default_projector_for_amendment_in_meeting_id integer,
    used_as_default_projector_for_motion_block_in_meeting_id integer,
    used_as_default_projector_for_assignment_in_meeting_id integer,
    used_as_default_projector_for_mediafile_in_meeting_id integer,
    used_as_default_projector_for_message_in_meeting_id integer,
    used_as_default_projector_for_countdown_in_meeting_id integer,
    used_as_default_projector_for_assignment_poll_in_meeting_id integer,
    used_as_default_projector_for_motion_poll_in_meeting_id integer,
    used_as_default_projector_for_poll_in_meeting_id integer,
    meeting_id integer NOT NULL
);



comment on column projectorT.sequential_number is 'The (positive) serial number of this model in its meeting. This number is auto-generated and read-only.';


CREATE TABLE IF NOT EXISTS projectionT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    options jsonb,
    stable boolean DEFAULT False,
    weight integer,
    type varchar(256),
    current_projector_id integer,
    preview_projector_id integer,
    history_projector_id integer,
    content_object_id varchar(100) NOT NULL,
    content_object_id_meeting_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'meeting' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_motion_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'motion' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_mediafile_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'mediafile' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_list_of_speakers_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'list_of_speakers' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_motion_block_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'motion_block' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_assignment_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'assignment' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_agenda_item_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'agenda_item' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_topic_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'topic' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_poll_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'poll' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_projector_message_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'projector_message' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    content_object_id_projector_countdown_id integer GENERATED ALWAYS AS (CASE WHEN split_part(content_object_id, '/', 1) = 'projector_countdown' THEN cast(split_part(content_object_id, '/', 2) AS INTEGER) ELSE null END) STORED,
    CONSTRAINT valid_content_object_id_part1 CHECK (split_part(content_object_id, '/', 1) IN ('meeting','motion','mediafile','list_of_speakers','motion_block','assignment','agenda_item','topic','poll','projector_message','projector_countdown')),
    meeting_id integer NOT NULL
);



/*
 Fields without SQL definition for table projection

    content type:JSON is marked as a calculated field

*/

CREATE TABLE IF NOT EXISTS projector_messageT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    message text,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS projector_countdownT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    title varchar(256) NOT NULL,
    description varchar(256) DEFAULT '',
    default_time integer,
    countdown_time real DEFAULT 60,
    running boolean DEFAULT False,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS chat_groupT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name varchar(256) NOT NULL,
    weight integer DEFAULT 10000,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS chat_messageT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    content text NOT NULL,
    created timestamptz NOT NULL,
    meeting_user_id integer NOT NULL,
    chat_group_id integer NOT NULL,
    meeting_id integer NOT NULL
);




CREATE TABLE IF NOT EXISTS action_workerT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name varchar(256) NOT NULL,
    state enum_action_worker_state NOT NULL,
    created timestamptz NOT NULL,
    timestamp timestamptz NOT NULL,
    result jsonb
);




CREATE TABLE IF NOT EXISTS import_previewT (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name enum_import_preview_name NOT NULL,
    state enum_import_preview_state NOT NULL,
    created timestamptz NOT NULL,
    result jsonb
);





-- Intermediate table definitions

CREATE TABLE IF NOT EXISTS nm_meeting_user_supported_motion_ids_motionT (
    meeting_user_id integer NOT NULL REFERENCES meeting_userT (id),
    motion_id integer NOT NULL REFERENCES motionT (id),
    PRIMARY KEY (meeting_user_id, motion_id)
);

CREATE TABLE IF NOT EXISTS nm_meeting_user_structure_level_ids_structure_levelT (
    meeting_user_id integer NOT NULL REFERENCES meeting_userT (id),
    structure_level_id integer NOT NULL REFERENCES structure_levelT (id),
    PRIMARY KEY (meeting_user_id, structure_level_id)
);

CREATE TABLE IF NOT EXISTS gm_organization_tag_tagged_idsT (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    organization_tag_id integer NOT NULL REFERENCES organization_tagT(id),
    tagged_id varchar(100) NOT NULL,
    tagged_id_committee_id integer GENERATED ALWAYS AS (CASE WHEN split_part(tagged_id, '/', 1) = 'committee' THEN cast(split_part(tagged_id, '/', 2) AS INTEGER) ELSE null END) STORED REFERENCES committeeT(id),
    tagged_id_meeting_id integer GENERATED ALWAYS AS (CASE WHEN split_part(tagged_id, '/', 1) = 'meeting' THEN cast(split_part(tagged_id, '/', 2) AS INTEGER) ELSE null END) STORED REFERENCES meetingT(id),
    CONSTRAINT valid_tagged_id_part1 CHECK (split_part(tagged_id, '/', 1) IN ('committee', 'meeting')),
    CONSTRAINT unique_$organization_tag_id_$tagged_id UNIQUE (organization_tag_id, tagged_id)
);

CREATE TABLE IF NOT EXISTS nm_committee_manager_ids_userT (
    committee_id integer NOT NULL REFERENCES committeeT (id),
    user_id integer NOT NULL REFERENCES userT (id),
    PRIMARY KEY (committee_id, user_id)
);

CREATE TABLE IF NOT EXISTS nm_committee_forward_to_committee_ids_committeeT (
    forward_to_committee_id integer NOT NULL REFERENCES committeeT (id),
    receive_forwardings_from_committee_id integer NOT NULL REFERENCES committeeT (id),
    PRIMARY KEY (forward_to_committee_id, receive_forwardings_from_committee_id)
);

CREATE TABLE IF NOT EXISTS nm_meeting_present_user_ids_userT (
    meeting_id integer NOT NULL REFERENCES meetingT (id),
    user_id integer NOT NULL REFERENCES userT (id),
    PRIMARY KEY (meeting_id, user_id)
);

CREATE TABLE IF NOT EXISTS nm_group_meeting_user_ids_meeting_userT (
    group_id integer NOT NULL REFERENCES groupT (id),
    meeting_user_id integer NOT NULL REFERENCES meeting_userT (id),
    PRIMARY KEY (group_id, meeting_user_id)
);

CREATE TABLE IF NOT EXISTS nm_group_mediafile_access_group_ids_mediafileT (
    group_id integer NOT NULL REFERENCES groupT (id),
    mediafile_id integer NOT NULL REFERENCES mediafileT (id),
    PRIMARY KEY (group_id, mediafile_id)
);

CREATE TABLE IF NOT EXISTS nm_group_mediafile_inherited_access_group_ids_mediafileT (
    group_id integer NOT NULL REFERENCES groupT (id),
    mediafile_id integer NOT NULL REFERENCES mediafileT (id),
    PRIMARY KEY (group_id, mediafile_id)
);

CREATE TABLE IF NOT EXISTS nm_group_read_comment_section_ids_motion_comment_sectionT (
    group_id integer NOT NULL REFERENCES groupT (id),
    motion_comment_section_id integer NOT NULL REFERENCES motion_comment_sectionT (id),
    PRIMARY KEY (group_id, motion_comment_section_id)
);

CREATE TABLE IF NOT EXISTS nm_group_write_comment_section_ids_motion_comment_sectionT (
    group_id integer NOT NULL REFERENCES groupT (id),
    motion_comment_section_id integer NOT NULL REFERENCES motion_comment_sectionT (id),
    PRIMARY KEY (group_id, motion_comment_section_id)
);

CREATE TABLE IF NOT EXISTS nm_group_poll_ids_pollT (
    group_id integer NOT NULL REFERENCES groupT (id),
    poll_id integer NOT NULL REFERENCES pollT (id),
    PRIMARY KEY (group_id, poll_id)
);

CREATE TABLE IF NOT EXISTS gm_tag_tagged_idsT (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tag_id integer NOT NULL REFERENCES tagT(id),
    tagged_id varchar(100) NOT NULL,
    tagged_id_agenda_item_id integer GENERATED ALWAYS AS (CASE WHEN split_part(tagged_id, '/', 1) = 'agenda_item' THEN cast(split_part(tagged_id, '/', 2) AS INTEGER) ELSE null END) STORED REFERENCES agenda_itemT(id),
    tagged_id_assignment_id integer GENERATED ALWAYS AS (CASE WHEN split_part(tagged_id, '/', 1) = 'assignment' THEN cast(split_part(tagged_id, '/', 2) AS INTEGER) ELSE null END) STORED REFERENCES assignmentT(id),
    tagged_id_motion_id integer GENERATED ALWAYS AS (CASE WHEN split_part(tagged_id, '/', 1) = 'motion' THEN cast(split_part(tagged_id, '/', 2) AS INTEGER) ELSE null END) STORED REFERENCES motionT(id),
    CONSTRAINT valid_tagged_id_part1 CHECK (split_part(tagged_id, '/', 1) IN ('agenda_item', 'assignment', 'motion')),
    CONSTRAINT unique_$tag_id_$tagged_id UNIQUE (tag_id, tagged_id)
);

CREATE TABLE IF NOT EXISTS nm_motion_all_derived_motion_ids_motionT (
    all_derived_motion_id integer NOT NULL REFERENCES motionT (id),
    all_origin_id integer NOT NULL REFERENCES motionT (id),
    PRIMARY KEY (all_derived_motion_id, all_origin_id)
);

CREATE TABLE IF NOT EXISTS gm_motion_state_extension_reference_idsT (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    motion_id integer NOT NULL REFERENCES motionT(id),
    state_extension_reference_id varchar(100) NOT NULL,
    state_extension_reference_id_motion_id integer GENERATED ALWAYS AS (CASE WHEN split_part(state_extension_reference_id, '/', 1) = 'motion' THEN cast(split_part(state_extension_reference_id, '/', 2) AS INTEGER) ELSE null END) STORED REFERENCES motionT(id),
    CONSTRAINT valid_state_extension_reference_id_part1 CHECK (split_part(state_extension_reference_id, '/', 1) IN ('motion')),
    CONSTRAINT unique_$motion_id_$state_extension_reference_id UNIQUE (motion_id, state_extension_reference_id)
);

CREATE TABLE IF NOT EXISTS gm_motion_recommendation_extension_reference_idsT (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    motion_id integer NOT NULL REFERENCES motionT(id),
    recommendation_extension_reference_id varchar(100) NOT NULL,
    recommendation_extension_reference_id_motion_id integer GENERATED ALWAYS AS (CASE WHEN split_part(recommendation_extension_reference_id, '/', 1) = 'motion' THEN cast(split_part(recommendation_extension_reference_id, '/', 2) AS INTEGER) ELSE null END) STORED REFERENCES motionT(id),
    CONSTRAINT valid_recommendation_extension_reference_id_part1 CHECK (split_part(recommendation_extension_reference_id, '/', 1) IN ('motion')),
    CONSTRAINT unique_$motion_id_$recommendation_extension_reference_id UNIQUE (motion_id, recommendation_extension_reference_id)
);

CREATE TABLE IF NOT EXISTS nm_motion_state_next_state_ids_motion_stateT (
    next_state_id integer NOT NULL REFERENCES motion_stateT (id),
    previous_state_id integer NOT NULL REFERENCES motion_stateT (id),
    PRIMARY KEY (next_state_id, previous_state_id)
);

CREATE TABLE IF NOT EXISTS nm_poll_voted_ids_userT (
    poll_id integer NOT NULL REFERENCES pollT (id),
    user_id integer NOT NULL REFERENCES userT (id),
    PRIMARY KEY (poll_id, user_id)
);

CREATE TABLE IF NOT EXISTS gm_mediafile_attachment_idsT (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    mediafile_id integer NOT NULL REFERENCES mediafileT(id),
    attachment_id varchar(100) NOT NULL,
    attachment_id_motion_id integer GENERATED ALWAYS AS (CASE WHEN split_part(attachment_id, '/', 1) = 'motion' THEN cast(split_part(attachment_id, '/', 2) AS INTEGER) ELSE null END) STORED REFERENCES motionT(id),
    attachment_id_topic_id integer GENERATED ALWAYS AS (CASE WHEN split_part(attachment_id, '/', 1) = 'topic' THEN cast(split_part(attachment_id, '/', 2) AS INTEGER) ELSE null END) STORED REFERENCES topicT(id),
    attachment_id_assignment_id integer GENERATED ALWAYS AS (CASE WHEN split_part(attachment_id, '/', 1) = 'assignment' THEN cast(split_part(attachment_id, '/', 2) AS INTEGER) ELSE null END) STORED REFERENCES assignmentT(id),
    CONSTRAINT valid_attachment_id_part1 CHECK (split_part(attachment_id, '/', 1) IN ('motion', 'topic', 'assignment')),
    CONSTRAINT unique_$mediafile_id_$attachment_id UNIQUE (mediafile_id, attachment_id)
);

CREATE TABLE IF NOT EXISTS nm_chat_group_read_group_ids_groupT (
    chat_group_id integer NOT NULL REFERENCES chat_groupT (id),
    group_id integer NOT NULL REFERENCES groupT (id),
    PRIMARY KEY (chat_group_id, group_id)
);

CREATE TABLE IF NOT EXISTS nm_chat_group_write_group_ids_groupT (
    chat_group_id integer NOT NULL REFERENCES chat_groupT (id),
    group_id integer NOT NULL REFERENCES groupT (id),
    PRIMARY KEY (chat_group_id, group_id)
);
-- View definitions

CREATE OR REPLACE VIEW organization AS SELECT *,
(select array_agg(m.id) from meetingT m where m.is_active_in_organization_id = o.id) as active_meeting_ids,
(select array_agg(m.id) from meetingT m where m.is_archived_in_organization_id = o.id) as archived_meeting_ids,
(select array_agg(m.id) from meetingT m where m.template_for_organization_id = o.id) as template_meeting_ids,
(select array_agg(m.id) from mediafileT m where m.owner_id_organization_id = o.id) as mediafile_ids
FROM organizationT o;


CREATE OR REPLACE VIEW user_ AS SELECT *,
(select array_agg(n.meeting_id) from nm_meeting_present_user_ids_userT n where n.user_id = u.id) as is_present_in_meeting_ids,
(select array_agg(n.committee_id) from nm_committee_manager_ids_userT n where n.user_id = u.id) as committee_management_ids,
(select array_agg(c.id) from committeeT c where c.forwarding_user_id = u.id) as forwarding_committee_ids,
(select array_agg(m.id) from meeting_userT m where m.user_id = u.id) as meeting_user_ids,
(select array_agg(n.poll_id) from nm_poll_voted_ids_userT n where n.user_id = u.id) as poll_voted_ids,
(select array_agg(o.id) from optionT o where o.content_object_id_user_id = u.id) as option_ids,
(select array_agg(v.id) from voteT v where v.user_id = u.id) as vote_ids,
(select array_agg(v.id) from voteT v where v.delegated_user_id = u.id) as delegated_vote_ids,
(select array_agg(p.id) from poll_candidateT p where p.user_id = u.id) as poll_candidate_ids
FROM userT u;


CREATE OR REPLACE VIEW meeting_user AS SELECT *,
(select array_agg(p.id) from personal_noteT p where p.meeting_user_id = m.id) as personal_note_ids,
(select array_agg(s.id) from speakerT s where s.meeting_user_id = m.id) as speaker_ids,
(select array_agg(n.motion_id) from nm_meeting_user_supported_motion_ids_motionT n where n.meeting_user_id = m.id) as supported_motion_ids,
(select array_agg(me.id) from motion_editorT me where me.meeting_user_id = m.id) as motion_editor_ids,
(select array_agg(mw.id) from motion_working_group_speakerT mw where mw.meeting_user_id = m.id) as motion_working_group_speaker_ids,
(select array_agg(ms.id) from motion_submitterT ms where ms.meeting_user_id = m.id) as motion_submitter_ids,
(select array_agg(a.id) from assignment_candidateT a where a.meeting_user_id = m.id) as assignment_candidate_ids,
(select array_agg(mu.id) from meeting_userT mu where mu.vote_delegated_to_id = m.id) as vote_delegations_from_ids,
(select array_agg(c.id) from chat_messageT c where c.meeting_user_id = m.id) as chat_message_ids,
(select array_agg(n.group_id) from nm_group_meeting_user_ids_meeting_userT n where n.meeting_user_id = m.id) as group_ids,
(select array_agg(n.structure_level_id) from nm_meeting_user_structure_level_ids_structure_levelT n where n.meeting_user_id = m.id) as structure_level_ids
FROM meeting_userT m;


CREATE OR REPLACE VIEW organization_tag AS SELECT *,
(select array_agg(g.id) from gm_organization_tag_tagged_idsT g where g.organization_tag_id = o.id) as tagged_ids
FROM organization_tagT o;


CREATE OR REPLACE VIEW committee AS SELECT *,
(select array_agg(m.id) from meetingT m where m.committee_id = c.id) as meeting_ids,
(select array_agg(n.user_id) from nm_committee_manager_ids_userT n where n.committee_id = c.id) as manager_ids,
(select array_agg(n.forward_to_committee_id) from nm_committee_forward_to_committee_ids_committeeT n where n.receive_forwardings_from_committee_id = c.id) as forward_to_committee_ids,
(select array_agg(n.receive_forwardings_from_committee_id) from nm_committee_forward_to_committee_ids_committeeT n where n.forward_to_committee_id = c.id) as receive_forwardings_from_committee_ids,
(select array_agg(g.organization_tag_id) from gm_organization_tag_tagged_idsT g where g.tagged_id_committee_id = c.id) as organization_tag_ids
FROM committeeT c;


CREATE OR REPLACE VIEW meeting AS SELECT *,
(select array_agg(g.id) from groupT g where g.used_as_motion_poll_default_id = m.id) as motion_poll_default_group_ids,
(select array_agg(p.id) from poll_candidate_listT p where p.meeting_id = m.id) as poll_candidate_list_ids,
(select array_agg(p.id) from poll_candidateT p where p.meeting_id = m.id) as poll_candidate_ids,
(select array_agg(mu.id) from meeting_userT mu where mu.meeting_id = m.id) as meeting_user_ids,
(select array_agg(g.id) from groupT g where g.used_as_assignment_poll_default_id = m.id) as assignment_poll_default_group_ids,
(select array_agg(g.id) from groupT g where g.used_as_poll_default_id = m.id) as poll_default_group_ids,
(select array_agg(g.id) from groupT g where g.used_as_topic_poll_default_id = m.id) as topic_poll_default_group_ids,
(select array_agg(p.id) from projectorT p where p.meeting_id = m.id) as projector_ids,
(select array_agg(p.id) from projectionT p where p.meeting_id = m.id) as all_projection_ids,
(select array_agg(p.id) from projector_messageT p where p.meeting_id = m.id) as projector_message_ids,
(select array_agg(p.id) from projector_countdownT p where p.meeting_id = m.id) as projector_countdown_ids,
(select array_agg(t.id) from tagT t where t.meeting_id = m.id) as tag_ids,
(select array_agg(a.id) from agenda_itemT a where a.meeting_id = m.id) as agenda_item_ids,
(select array_agg(l.id) from list_of_speakersT l where l.meeting_id = m.id) as list_of_speakers_ids,
(select array_agg(s.id) from structure_level_list_of_speakersT s where s.meeting_id = m.id) as structure_level_list_of_speakers_ids,
(select array_agg(p.id) from point_of_order_categoryT p where p.meeting_id = m.id) as point_of_order_category_ids,
(select array_agg(s.id) from speakerT s where s.meeting_id = m.id) as speaker_ids,
(select array_agg(t.id) from topicT t where t.meeting_id = m.id) as topic_ids,
(select array_agg(g.id) from groupT g where g.meeting_id = m.id) as group_ids,
(select array_agg(m1.id) from mediafileT m1 where m1.owner_id_meeting_id = m.id) as mediafile_ids,
(select array_agg(m1.id) from motionT m1 where m1.meeting_id = m.id) as motion_ids,
(select array_agg(m1.id) from motionT m1 where m1.origin_meeting_id = m.id) as forwarded_motion_ids,
(select array_agg(mc.id) from motion_comment_sectionT mc where mc.meeting_id = m.id) as motion_comment_section_ids,
(select array_agg(mc.id) from motion_categoryT mc where mc.meeting_id = m.id) as motion_category_ids,
(select array_agg(mb.id) from motion_blockT mb where mb.meeting_id = m.id) as motion_block_ids,
(select array_agg(mw.id) from motion_workflowT mw where mw.meeting_id = m.id) as motion_workflow_ids,
(select array_agg(ms.id) from motion_statute_paragraphT ms where ms.meeting_id = m.id) as motion_statute_paragraph_ids,
(select array_agg(mc.id) from motion_commentT mc where mc.meeting_id = m.id) as motion_comment_ids,
(select array_agg(ms.id) from motion_submitterT ms where ms.meeting_id = m.id) as motion_submitter_ids,
(select array_agg(me.id) from motion_editorT me where me.meeting_id = m.id) as motion_editor_ids,
(select array_agg(mw.id) from motion_working_group_speakerT mw where mw.meeting_id = m.id) as motion_working_group_speaker_ids,
(select array_agg(mc.id) from motion_change_recommendationT mc where mc.meeting_id = m.id) as motion_change_recommendation_ids,
(select array_agg(ms.id) from motion_stateT ms where ms.meeting_id = m.id) as motion_state_ids,
(select array_agg(p.id) from pollT p where p.meeting_id = m.id) as poll_ids,
(select array_agg(o.id) from optionT o where o.meeting_id = m.id) as option_ids,
(select array_agg(v.id) from voteT v where v.meeting_id = m.id) as vote_ids,
(select array_agg(a.id) from assignmentT a where a.meeting_id = m.id) as assignment_ids,
(select array_agg(a.id) from assignment_candidateT a where a.meeting_id = m.id) as assignment_candidate_ids,
(select array_agg(p.id) from personal_noteT p where p.meeting_id = m.id) as personal_note_ids,
(select array_agg(c.id) from chat_groupT c where c.meeting_id = m.id) as chat_group_ids,
(select array_agg(c.id) from chat_messageT c where c.meeting_id = m.id) as chat_message_ids,
(select array_agg(s.id) from structure_levelT s where s.meeting_id = m.id) as structure_level_ids,
(select array_agg(g.organization_tag_id) from gm_organization_tag_tagged_idsT g where g.tagged_id_meeting_id = m.id) as organization_tag_ids,
(select array_agg(n.user_id) from nm_meeting_present_user_ids_userT n where n.meeting_id = m.id) as present_user_ids,
(select array_agg(p.id) from projectionT p where p.content_object_id_meeting_id = m.id) as projection_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_agenda_item_list_in_meeting_id = m.id) as default_projector_agenda_item_list_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_topic_in_meeting_id = m.id) as default_projector_topic_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_list_of_speakers_in_meeting_id = m.id) as default_projector_list_of_speakers_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_current_los_in_meeting_id = m.id) as default_projector_current_list_of_speakers_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_motion_in_meeting_id = m.id) as default_projector_motion_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_amendment_in_meeting_id = m.id) as default_projector_amendment_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_motion_block_in_meeting_id = m.id) as default_projector_motion_block_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_assignment_in_meeting_id = m.id) as default_projector_assignment_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_mediafile_in_meeting_id = m.id) as default_projector_mediafile_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_message_in_meeting_id = m.id) as default_projector_message_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_countdown_in_meeting_id = m.id) as default_projector_countdown_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_assignment_poll_in_meeting_id = m.id) as default_projector_assignment_poll_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_motion_poll_in_meeting_id = m.id) as default_projector_motion_poll_ids,
(select array_agg(p.id) from projectorT p where p.used_as_default_projector_for_poll_in_meeting_id = m.id) as default_projector_poll_ids
FROM meetingT m;


CREATE OR REPLACE VIEW structure_level AS SELECT *,
(select array_agg(n.meeting_user_id) from nm_meeting_user_structure_level_ids_structure_levelT n where n.structure_level_id = s.id) as meeting_user_ids,
(select array_agg(sl.id) from structure_level_list_of_speakersT sl where sl.structure_level_id = s.id) as structure_level_list_of_speakers_ids
FROM structure_levelT s;


CREATE OR REPLACE VIEW group_ AS SELECT *,
(select array_agg(n.meeting_user_id) from nm_group_meeting_user_ids_meeting_userT n where n.group_id = g.id) as meeting_user_ids,
(select m.id from meetingT m where m.default_group_id = g.id) as default_group_for_meeting_id,
(select array_agg(n.mediafile_id) from nm_group_mediafile_access_group_ids_mediafileT n where n.group_id = g.id) as mediafile_access_group_ids,
(select array_agg(n.mediafile_id) from nm_group_mediafile_inherited_access_group_ids_mediafileT n where n.group_id = g.id) as mediafile_inherited_access_group_ids,
(select array_agg(n.motion_comment_section_id) from nm_group_read_comment_section_ids_motion_comment_sectionT n where n.group_id = g.id) as read_comment_section_ids,
(select array_agg(n.motion_comment_section_id) from nm_group_write_comment_section_ids_motion_comment_sectionT n where n.group_id = g.id) as write_comment_section_ids,
(select array_agg(n.chat_group_id) from nm_chat_group_read_group_ids_groupT n where n.group_id = g.id) as read_chat_group_ids,
(select array_agg(n.chat_group_id) from nm_chat_group_write_group_ids_groupT n where n.group_id = g.id) as write_chat_group_ids,
(select array_agg(n.poll_id) from nm_group_poll_ids_pollT n where n.group_id = g.id) as poll_ids
FROM groupT g;


CREATE OR REPLACE VIEW tag AS SELECT *,
(select array_agg(g.id) from gm_tag_tagged_idsT g where g.tag_id = t.id) as tagged_ids
FROM tagT t;


CREATE OR REPLACE VIEW agenda_item AS SELECT *,
(select array_agg(ai.id) from agenda_itemT ai where ai.parent_id = a.id) as child_ids,
(select array_agg(g.tag_id) from gm_tag_tagged_idsT g where g.tagged_id_agenda_item_id = a.id) as tag_ids,
(select array_agg(p.id) from projectionT p where p.content_object_id_agenda_item_id = a.id) as projection_ids
FROM agenda_itemT a;


CREATE OR REPLACE VIEW list_of_speakers AS SELECT *,
(select array_agg(s.id) from speakerT s where s.list_of_speakers_id = l.id) as speaker_ids,
(select array_agg(s.id) from structure_level_list_of_speakersT s where s.list_of_speakers_id = l.id) as structure_level_list_of_speakers_ids,
(select array_agg(p.id) from projectionT p where p.content_object_id_list_of_speakers_id = l.id) as projection_ids
FROM list_of_speakersT l;


CREATE OR REPLACE VIEW structure_level_list_of_speakers AS SELECT *,
(select array_agg(s1.id) from speakerT s1 where s1.structure_level_list_of_speakers_id = s.id) as speaker_ids
FROM structure_level_list_of_speakersT s;


CREATE OR REPLACE VIEW point_of_order_category AS SELECT *,
(select array_agg(s.id) from speakerT s where s.point_of_order_category_id = p.id) as speaker_ids
FROM point_of_order_categoryT p;


CREATE OR REPLACE VIEW topic AS SELECT *,
(select array_agg(g.mediafile_id) from gm_mediafile_attachment_idsT g where g.attachment_id_topic_id = t.id) as attachment_ids,
(select a.id from agenda_itemT a where a.content_object_id_topic_id = t.id) as agenda_item_id,
(select l.id from list_of_speakersT l where l.content_object_id_topic_id = t.id) as list_of_speakers_id,
(select array_agg(p.id) from pollT p where p.content_object_id_topic_id = t.id) as poll_ids,
(select array_agg(p.id) from projectionT p where p.content_object_id_topic_id = t.id) as projection_ids
FROM topicT t;


CREATE OR REPLACE VIEW motion AS SELECT *,
(select array_agg(m1.id) from motionT m1 where m1.lead_motion_id = m.id) as amendment_ids,
(select array_agg(m1.id) from motionT m1 where m1.sort_parent_id = m.id) as sort_child_ids,
(select array_agg(m1.id) from motionT m1 where m1.origin_id = m.id) as derived_motion_ids,
(select array_agg(n.all_origin_id) from nm_motion_all_derived_motion_ids_motionT n where n.all_derived_motion_id = m.id) as all_origin_ids,
(select array_agg(n.all_derived_motion_id) from nm_motion_all_derived_motion_ids_motionT n where n.all_origin_id = m.id) as all_derived_motion_ids,
(select array_agg(g.id) from gm_motion_state_extension_reference_idsT g where g.motion_id = m.id) as state_extension_reference_ids,
(select array_agg(g.motion_id) from gm_motion_state_extension_reference_idsT g where g.state_extension_reference_id_motion_id = m.id) as referenced_in_motion_state_extension_ids,
(select array_agg(g.id) from gm_motion_recommendation_extension_reference_idsT g where g.motion_id = m.id) as recommendation_extension_reference_ids,
(select array_agg(g.motion_id) from gm_motion_recommendation_extension_reference_idsT g where g.recommendation_extension_reference_id_motion_id = m.id) as referenced_in_motion_recommendation_extension_ids,
(select array_agg(ms.id) from motion_submitterT ms where ms.motion_id = m.id) as submitter_ids,
(select array_agg(n.meeting_user_id) from nm_meeting_user_supported_motion_ids_motionT n where n.motion_id = m.id) as supporter_meeting_user_ids,
(select array_agg(me.id) from motion_editorT me where me.motion_id = m.id) as editor_ids,
(select array_agg(mw.id) from motion_working_group_speakerT mw where mw.motion_id = m.id) as working_group_speaker_ids,
(select array_agg(p.id) from pollT p where p.content_object_id_motion_id = m.id) as poll_ids,
(select array_agg(o.id) from optionT o where o.content_object_id_motion_id = m.id) as option_ids,
(select array_agg(mc.id) from motion_change_recommendationT mc where mc.motion_id = m.id) as change_recommendation_ids,
(select array_agg(mc.id) from motion_commentT mc where mc.motion_id = m.id) as comment_ids,
(select a.id from agenda_itemT a where a.content_object_id_motion_id = m.id) as agenda_item_id,
(select l.id from list_of_speakersT l where l.content_object_id_motion_id = m.id) as list_of_speakers_id,
(select array_agg(g.tag_id) from gm_tag_tagged_idsT g where g.tagged_id_motion_id = m.id) as tag_ids,
(select array_agg(g.mediafile_id) from gm_mediafile_attachment_idsT g where g.attachment_id_motion_id = m.id) as attachment_ids,
(select array_agg(p.id) from projectionT p where p.content_object_id_motion_id = m.id) as projection_ids,
(select array_agg(p.id) from personal_noteT p where p.content_object_id_motion_id = m.id) as personal_note_ids
FROM motionT m;


CREATE OR REPLACE VIEW motion_comment_section AS SELECT *,
(select array_agg(mc.id) from motion_commentT mc where mc.section_id = m.id) as comment_ids,
(select array_agg(n.group_id) from nm_group_read_comment_section_ids_motion_comment_sectionT n where n.motion_comment_section_id = m.id) as read_group_ids,
(select array_agg(n.group_id) from nm_group_write_comment_section_ids_motion_comment_sectionT n where n.motion_comment_section_id = m.id) as write_group_ids
FROM motion_comment_sectionT m;


CREATE OR REPLACE VIEW motion_category AS SELECT *,
(select array_agg(mc.id) from motion_categoryT mc where mc.parent_id = m.id) as child_ids,
(select array_agg(m1.id) from motionT m1 where m1.category_id = m.id) as motion_ids
FROM motion_categoryT m;


CREATE OR REPLACE VIEW motion_block AS SELECT *,
(select array_agg(m1.id) from motionT m1 where m1.block_id = m.id) as motion_ids,
(select a.id from agenda_itemT a where a.content_object_id_motion_block_id = m.id) as agenda_item_id,
(select l.id from list_of_speakersT l where l.content_object_id_motion_block_id = m.id) as list_of_speakers_id,
(select array_agg(p.id) from projectionT p where p.content_object_id_motion_block_id = m.id) as projection_ids
FROM motion_blockT m;


CREATE OR REPLACE VIEW motion_state AS SELECT *,
(select array_agg(ms.id) from motion_stateT ms where ms.submitter_withdraw_state_id = m.id) as submitter_withdraw_back_ids,
(select array_agg(n.next_state_id) from nm_motion_state_next_state_ids_motion_stateT n where n.previous_state_id = m.id) as next_state_ids,
(select array_agg(n.previous_state_id) from nm_motion_state_next_state_ids_motion_stateT n where n.next_state_id = m.id) as previous_state_ids,
(select array_agg(m1.id) from motionT m1 where m1.state_id = m.id) as motion_ids,
(select array_agg(m1.id) from motionT m1 where m1.recommendation_id = m.id) as motion_recommendation_ids,
(select mw.id from motion_workflowT mw where mw.first_state_id = m.id) as first_state_of_workflow_id
FROM motion_stateT m;


CREATE OR REPLACE VIEW motion_workflow AS SELECT *,
(select array_agg(ms.id) from motion_stateT ms where ms.workflow_id = m.id) as state_ids,
(select m1.id from meetingT m1 where m1.motions_default_workflow_id = m.id) as default_workflow_meeting_id,
(select m1.id from meetingT m1 where m1.motions_default_amendment_workflow_id = m.id) as default_amendment_workflow_meeting_id,
(select m1.id from meetingT m1 where m1.motions_default_statute_amendment_workflow_id = m.id) as default_statute_amendment_workflow_meeting_id
FROM motion_workflowT m;


CREATE OR REPLACE VIEW motion_statute_paragraph AS SELECT *,
(select array_agg(m1.id) from motionT m1 where m1.statute_paragraph_id = m.id) as motion_ids
FROM motion_statute_paragraphT m;


CREATE OR REPLACE VIEW poll AS SELECT *,
(select array_agg(o.id) from optionT o where o.poll_id = p.id) as option_ids,
(select array_agg(n.user_id) from nm_poll_voted_ids_userT n where n.poll_id = p.id) as voted_ids,
(select array_agg(n.group_id) from nm_group_poll_ids_pollT n where n.poll_id = p.id) as entitled_group_ids,
(select array_agg(p1.id) from projectionT p1 where p1.content_object_id_poll_id = p.id) as projection_ids
FROM pollT p;


CREATE OR REPLACE VIEW option AS SELECT *,
(select array_agg(v.id) from voteT v where v.option_id = o.id) as vote_ids
FROM optionT o;


CREATE OR REPLACE VIEW assignment AS SELECT *,
(select array_agg(ac.id) from assignment_candidateT ac where ac.assignment_id = a.id) as candidate_ids,
(select array_agg(p.id) from pollT p where p.content_object_id_assignment_id = a.id) as poll_ids,
(select ai.id from agenda_itemT ai where ai.content_object_id_assignment_id = a.id) as agenda_item_id,
(select l.id from list_of_speakersT l where l.content_object_id_assignment_id = a.id) as list_of_speakers_id,
(select array_agg(g.tag_id) from gm_tag_tagged_idsT g where g.tagged_id_assignment_id = a.id) as tag_ids,
(select array_agg(g.mediafile_id) from gm_mediafile_attachment_idsT g where g.attachment_id_assignment_id = a.id) as attachment_ids,
(select array_agg(p.id) from projectionT p where p.content_object_id_assignment_id = a.id) as projection_ids
FROM assignmentT a;


CREATE OR REPLACE VIEW poll_candidate_list AS SELECT *,
(select array_agg(pc.id) from poll_candidateT pc where pc.poll_candidate_list_id = p.id) as poll_candidate_ids,
(select o.id from optionT o where o.content_object_id_poll_candidate_list_id = p.id) as option_id
FROM poll_candidate_listT p;


CREATE OR REPLACE VIEW mediafile AS SELECT *,
(select array_agg(n.group_id) from nm_group_mediafile_inherited_access_group_ids_mediafileT n where n.mediafile_id = m.id) as inherited_access_group_ids,
(select array_agg(n.group_id) from nm_group_mediafile_access_group_ids_mediafileT n where n.mediafile_id = m.id) as access_group_ids,
(select array_agg(m1.id) from mediafileT m1 where m1.parent_id = m.id) as child_ids,
(select l.id from list_of_speakersT l where l.content_object_id_mediafile_id = m.id) as list_of_speakers_id,
(select array_agg(p.id) from projectionT p where p.content_object_id_mediafile_id = m.id) as projection_ids,
(select array_agg(g.id) from gm_mediafile_attachment_idsT g where g.mediafile_id = m.id) as attachment_ids
FROM mediafileT m;


CREATE OR REPLACE VIEW projector AS SELECT *,
(select array_agg(p1.id) from projectionT p1 where p1.current_projector_id = p.id) as current_projection_ids,
(select array_agg(p1.id) from projectionT p1 where p1.preview_projector_id = p.id) as preview_projection_ids,
(select array_agg(p1.id) from projectionT p1 where p1.history_projector_id = p.id) as history_projection_ids,
(select m.id from meetingT m where m.reference_projector_id = p.id) as used_as_reference_projector_meeting_id
FROM projectorT p;


CREATE OR REPLACE VIEW projector_message AS SELECT *,
(select array_agg(p1.id) from projectionT p1 where p1.content_object_id_projector_message_id = p.id) as projection_ids
FROM projector_messageT p;


CREATE OR REPLACE VIEW projector_countdown AS SELECT *,
(select array_agg(p1.id) from projectionT p1 where p1.content_object_id_projector_countdown_id = p.id) as projection_ids
FROM projector_countdownT p;


CREATE OR REPLACE VIEW chat_group AS SELECT *,
(select array_agg(cm.id) from chat_messageT cm where cm.chat_group_id = c.id) as chat_message_ids,
(select array_agg(n.group_id) from nm_chat_group_read_group_ids_groupT n where n.chat_group_id = c.id) as read_group_ids,
(select array_agg(n.group_id) from nm_chat_group_write_group_ids_groupT n where n.chat_group_id = c.id) as write_group_ids
FROM chat_groupT c;

-- Alter table relations
ALTER TABLE meeting_userT ADD FOREIGN KEY(user_id) REFERENCES userT(id);
ALTER TABLE meeting_userT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);
ALTER TABLE meeting_userT ADD FOREIGN KEY(vote_delegated_to_id) REFERENCES meeting_userT(id);

ALTER TABLE committeeT ADD FOREIGN KEY(forwarding_user_id) REFERENCES userT(id);

ALTER TABLE meetingT ADD FOREIGN KEY(is_active_in_organization_id) REFERENCES organizationT(id);
ALTER TABLE meetingT ADD FOREIGN KEY(is_archived_in_organization_id) REFERENCES organizationT(id);
ALTER TABLE meetingT ADD FOREIGN KEY(template_for_organization_id) REFERENCES organizationT(id);
ALTER TABLE meetingT ADD FOREIGN KEY(motions_default_workflow_id) REFERENCES motion_workflowT(id) INITIALLY DEFERRED;
ALTER TABLE meetingT ADD FOREIGN KEY(motions_default_amendment_workflow_id) REFERENCES motion_workflowT(id) INITIALLY DEFERRED;
ALTER TABLE meetingT ADD FOREIGN KEY(motions_default_statute_amendment_workflow_id) REFERENCES motion_workflowT(id) INITIALLY DEFERRED;
ALTER TABLE meetingT ADD FOREIGN KEY(committee_id) REFERENCES committeeT(id);
ALTER TABLE meetingT ADD FOREIGN KEY(reference_projector_id) REFERENCES projectorT(id) INITIALLY DEFERRED;
ALTER TABLE meetingT ADD FOREIGN KEY(default_group_id) REFERENCES groupT(id) INITIALLY DEFERRED;

ALTER TABLE structure_levelT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE groupT ADD FOREIGN KEY(used_as_motion_poll_default_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE groupT ADD FOREIGN KEY(used_as_assignment_poll_default_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE groupT ADD FOREIGN KEY(used_as_topic_poll_default_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE groupT ADD FOREIGN KEY(used_as_poll_default_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE groupT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;

ALTER TABLE personal_noteT ADD FOREIGN KEY(meeting_user_id) REFERENCES meeting_userT(id);
ALTER TABLE personal_noteT ADD FOREIGN KEY(content_object_id_motion_id) REFERENCES motionT(id);
ALTER TABLE personal_noteT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE tagT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE agenda_itemT ADD FOREIGN KEY(content_object_id_motion_id) REFERENCES motionT(id);
ALTER TABLE agenda_itemT ADD FOREIGN KEY(content_object_id_motion_block_id) REFERENCES motion_blockT(id);
ALTER TABLE agenda_itemT ADD FOREIGN KEY(content_object_id_assignment_id) REFERENCES assignmentT(id);
ALTER TABLE agenda_itemT ADD FOREIGN KEY(content_object_id_topic_id) REFERENCES topicT(id);
ALTER TABLE agenda_itemT ADD FOREIGN KEY(parent_id) REFERENCES agenda_itemT(id);
ALTER TABLE agenda_itemT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE list_of_speakersT ADD FOREIGN KEY(content_object_id_motion_id) REFERENCES motionT(id);
ALTER TABLE list_of_speakersT ADD FOREIGN KEY(content_object_id_motion_block_id) REFERENCES motion_blockT(id);
ALTER TABLE list_of_speakersT ADD FOREIGN KEY(content_object_id_assignment_id) REFERENCES assignmentT(id);
ALTER TABLE list_of_speakersT ADD FOREIGN KEY(content_object_id_topic_id) REFERENCES topicT(id);
ALTER TABLE list_of_speakersT ADD FOREIGN KEY(content_object_id_mediafile_id) REFERENCES mediafileT(id);
ALTER TABLE list_of_speakersT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE structure_level_list_of_speakersT ADD FOREIGN KEY(structure_level_id) REFERENCES structure_levelT(id);
ALTER TABLE structure_level_list_of_speakersT ADD FOREIGN KEY(list_of_speakers_id) REFERENCES list_of_speakersT(id);
ALTER TABLE structure_level_list_of_speakersT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE point_of_order_categoryT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE speakerT ADD FOREIGN KEY(list_of_speakers_id) REFERENCES list_of_speakersT(id);
ALTER TABLE speakerT ADD FOREIGN KEY(structure_level_list_of_speakers_id) REFERENCES structure_level_list_of_speakersT(id);
ALTER TABLE speakerT ADD FOREIGN KEY(meeting_user_id) REFERENCES meeting_userT(id);
ALTER TABLE speakerT ADD FOREIGN KEY(point_of_order_category_id) REFERENCES point_of_order_categoryT(id);
ALTER TABLE speakerT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE topicT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE motionT ADD FOREIGN KEY(lead_motion_id) REFERENCES motionT(id);
ALTER TABLE motionT ADD FOREIGN KEY(sort_parent_id) REFERENCES motionT(id);
ALTER TABLE motionT ADD FOREIGN KEY(origin_id) REFERENCES motionT(id);
ALTER TABLE motionT ADD FOREIGN KEY(origin_meeting_id) REFERENCES meetingT(id);
ALTER TABLE motionT ADD FOREIGN KEY(state_id) REFERENCES motion_stateT(id);
ALTER TABLE motionT ADD FOREIGN KEY(recommendation_id) REFERENCES motion_stateT(id);
ALTER TABLE motionT ADD FOREIGN KEY(category_id) REFERENCES motion_categoryT(id);
ALTER TABLE motionT ADD FOREIGN KEY(block_id) REFERENCES motion_blockT(id);
ALTER TABLE motionT ADD FOREIGN KEY(statute_paragraph_id) REFERENCES motion_statute_paragraphT(id);
ALTER TABLE motionT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE motion_submitterT ADD FOREIGN KEY(meeting_user_id) REFERENCES meeting_userT(id);
ALTER TABLE motion_submitterT ADD FOREIGN KEY(motion_id) REFERENCES motionT(id);
ALTER TABLE motion_submitterT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE motion_editorT ADD FOREIGN KEY(meeting_user_id) REFERENCES meeting_userT(id);
ALTER TABLE motion_editorT ADD FOREIGN KEY(motion_id) REFERENCES motionT(id);
ALTER TABLE motion_editorT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE motion_working_group_speakerT ADD FOREIGN KEY(meeting_user_id) REFERENCES meeting_userT(id);
ALTER TABLE motion_working_group_speakerT ADD FOREIGN KEY(motion_id) REFERENCES motionT(id);
ALTER TABLE motion_working_group_speakerT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE motion_commentT ADD FOREIGN KEY(motion_id) REFERENCES motionT(id);
ALTER TABLE motion_commentT ADD FOREIGN KEY(section_id) REFERENCES motion_comment_sectionT(id);
ALTER TABLE motion_commentT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE motion_comment_sectionT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE motion_categoryT ADD FOREIGN KEY(parent_id) REFERENCES motion_categoryT(id);
ALTER TABLE motion_categoryT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE motion_blockT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE motion_change_recommendationT ADD FOREIGN KEY(motion_id) REFERENCES motionT(id);
ALTER TABLE motion_change_recommendationT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE motion_stateT ADD FOREIGN KEY(submitter_withdraw_state_id) REFERENCES motion_stateT(id);
ALTER TABLE motion_stateT ADD FOREIGN KEY(workflow_id) REFERENCES motion_workflowT(id) INITIALLY DEFERRED;
ALTER TABLE motion_stateT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;

ALTER TABLE motion_workflowT ADD FOREIGN KEY(first_state_id) REFERENCES motion_stateT(id) INITIALLY DEFERRED;
ALTER TABLE motion_workflowT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;

ALTER TABLE motion_statute_paragraphT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE pollT ADD FOREIGN KEY(content_object_id_motion_id) REFERENCES motionT(id);
ALTER TABLE pollT ADD FOREIGN KEY(content_object_id_assignment_id) REFERENCES assignmentT(id);
ALTER TABLE pollT ADD FOREIGN KEY(content_object_id_topic_id) REFERENCES topicT(id);
ALTER TABLE pollT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE optionT ADD FOREIGN KEY(poll_id) REFERENCES pollT(id);
ALTER TABLE optionT ADD FOREIGN KEY(content_object_id_motion_id) REFERENCES motionT(id);
ALTER TABLE optionT ADD FOREIGN KEY(content_object_id_user_id) REFERENCES userT(id);
ALTER TABLE optionT ADD FOREIGN KEY(content_object_id_poll_candidate_list_id) REFERENCES poll_candidate_listT(id);
ALTER TABLE optionT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE voteT ADD FOREIGN KEY(option_id) REFERENCES optionT(id);
ALTER TABLE voteT ADD FOREIGN KEY(user_id) REFERENCES userT(id);
ALTER TABLE voteT ADD FOREIGN KEY(delegated_user_id) REFERENCES userT(id);
ALTER TABLE voteT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE assignmentT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE assignment_candidateT ADD FOREIGN KEY(assignment_id) REFERENCES assignmentT(id);
ALTER TABLE assignment_candidateT ADD FOREIGN KEY(meeting_user_id) REFERENCES meeting_userT(id);
ALTER TABLE assignment_candidateT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE poll_candidate_listT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE poll_candidateT ADD FOREIGN KEY(poll_candidate_list_id) REFERENCES poll_candidate_listT(id);
ALTER TABLE poll_candidateT ADD FOREIGN KEY(user_id) REFERENCES userT(id);
ALTER TABLE poll_candidateT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE mediafileT ADD FOREIGN KEY(parent_id) REFERENCES mediafileT(id);
ALTER TABLE mediafileT ADD FOREIGN KEY(owner_id_meeting_id) REFERENCES meetingT(id);
ALTER TABLE mediafileT ADD FOREIGN KEY(owner_id_organization_id) REFERENCES organizationT(id);

ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_agenda_item_list_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_topic_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_list_of_speakers_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_current_los_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_motion_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_amendment_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_motion_block_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_assignment_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_mediafile_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_message_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_countdown_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_assignment_poll_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_motion_poll_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(used_as_default_projector_for_poll_in_meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;
ALTER TABLE projectorT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id) INITIALLY DEFERRED;

ALTER TABLE projectionT ADD FOREIGN KEY(current_projector_id) REFERENCES projectorT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(preview_projector_id) REFERENCES projectorT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(history_projector_id) REFERENCES projectorT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(content_object_id_meeting_id) REFERENCES meetingT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(content_object_id_motion_id) REFERENCES motionT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(content_object_id_mediafile_id) REFERENCES mediafileT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(content_object_id_list_of_speakers_id) REFERENCES list_of_speakersT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(content_object_id_motion_block_id) REFERENCES motion_blockT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(content_object_id_assignment_id) REFERENCES assignmentT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(content_object_id_agenda_item_id) REFERENCES agenda_itemT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(content_object_id_topic_id) REFERENCES topicT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(content_object_id_poll_id) REFERENCES pollT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(content_object_id_projector_message_id) REFERENCES projector_messageT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(content_object_id_projector_countdown_id) REFERENCES projector_countdownT(id);
ALTER TABLE projectionT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE projector_messageT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE projector_countdownT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE chat_groupT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

ALTER TABLE chat_messageT ADD FOREIGN KEY(meeting_user_id) REFERENCES meeting_userT(id);
ALTER TABLE chat_messageT ADD FOREIGN KEY(chat_group_id) REFERENCES chat_groupT(id);
ALTER TABLE chat_messageT ADD FOREIGN KEY(meeting_id) REFERENCES meetingT(id);

-- Create trigger

-- definition trigger not null for meeting.default_projector_agenda_item_list_ids against projectorT.used_as_default_projector_for_agenda_item_list_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_agenda_item_list_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_agenda_item_list_ids', 'used_as_default_projector_for_agenda_item_list_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_agenda_item_list_ids AFTER UPDATE OF used_as_default_projector_for_agenda_item_list_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_agenda_item_list_ids', 'used_as_default_projector_for_agenda_item_list_in_meeting_id');


-- definition trigger not null for meeting.default_projector_topic_ids against projectorT.used_as_default_projector_for_topic_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_topic_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_topic_ids', 'used_as_default_projector_for_topic_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_topic_ids AFTER UPDATE OF used_as_default_projector_for_topic_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_topic_ids', 'used_as_default_projector_for_topic_in_meeting_id');


-- definition trigger not null for meeting.default_projector_list_of_speakers_ids against projectorT.used_as_default_projector_for_list_of_speakers_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_list_of_speakers_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_list_of_speakers_ids', 'used_as_default_projector_for_list_of_speakers_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_list_of_speakers_ids AFTER UPDATE OF used_as_default_projector_for_list_of_speakers_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_list_of_speakers_ids', 'used_as_default_projector_for_list_of_speakers_in_meeting_id');


-- definition trigger not null for meeting.default_projector_current_list_of_speakers_ids against projectorT.used_as_default_projector_for_current_los_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_current_list_of_speakers_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_current_list_of_speakers_ids', 'used_as_default_projector_for_current_los_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_current_list_of_speakers_ids AFTER UPDATE OF used_as_default_projector_for_current_los_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_current_list_of_speakers_ids', 'used_as_default_projector_for_current_los_in_meeting_id');


-- definition trigger not null for meeting.default_projector_motion_ids against projectorT.used_as_default_projector_for_motion_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_motion_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_motion_ids', 'used_as_default_projector_for_motion_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_motion_ids AFTER UPDATE OF used_as_default_projector_for_motion_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_motion_ids', 'used_as_default_projector_for_motion_in_meeting_id');


-- definition trigger not null for meeting.default_projector_amendment_ids against projectorT.used_as_default_projector_for_amendment_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_amendment_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_amendment_ids', 'used_as_default_projector_for_amendment_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_amendment_ids AFTER UPDATE OF used_as_default_projector_for_amendment_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_amendment_ids', 'used_as_default_projector_for_amendment_in_meeting_id');


-- definition trigger not null for meeting.default_projector_motion_block_ids against projectorT.used_as_default_projector_for_motion_block_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_motion_block_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_motion_block_ids', 'used_as_default_projector_for_motion_block_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_motion_block_ids AFTER UPDATE OF used_as_default_projector_for_motion_block_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_motion_block_ids', 'used_as_default_projector_for_motion_block_in_meeting_id');


-- definition trigger not null for meeting.default_projector_assignment_ids against projectorT.used_as_default_projector_for_assignment_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_assignment_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_assignment_ids', 'used_as_default_projector_for_assignment_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_assignment_ids AFTER UPDATE OF used_as_default_projector_for_assignment_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_assignment_ids', 'used_as_default_projector_for_assignment_in_meeting_id');


-- definition trigger not null for meeting.default_projector_mediafile_ids against projectorT.used_as_default_projector_for_mediafile_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_mediafile_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_mediafile_ids', 'used_as_default_projector_for_mediafile_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_mediafile_ids AFTER UPDATE OF used_as_default_projector_for_mediafile_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_mediafile_ids', 'used_as_default_projector_for_mediafile_in_meeting_id');


-- definition trigger not null for meeting.default_projector_message_ids against projectorT.used_as_default_projector_for_message_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_message_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_message_ids', 'used_as_default_projector_for_message_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_message_ids AFTER UPDATE OF used_as_default_projector_for_message_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_message_ids', 'used_as_default_projector_for_message_in_meeting_id');


-- definition trigger not null for meeting.default_projector_countdown_ids against projectorT.used_as_default_projector_for_countdown_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_countdown_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_countdown_ids', 'used_as_default_projector_for_countdown_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_countdown_ids AFTER UPDATE OF used_as_default_projector_for_countdown_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_countdown_ids', 'used_as_default_projector_for_countdown_in_meeting_id');


-- definition trigger not null for meeting.default_projector_assignment_poll_ids against projectorT.used_as_default_projector_for_assignment_poll_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_assignment_poll_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_assignment_poll_ids', 'used_as_default_projector_for_assignment_poll_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_assignment_poll_ids AFTER UPDATE OF used_as_default_projector_for_assignment_poll_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_assignment_poll_ids', 'used_as_default_projector_for_assignment_poll_in_meeting_id');


-- definition trigger not null for meeting.default_projector_motion_poll_ids against projectorT.used_as_default_projector_for_motion_poll_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_motion_poll_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_motion_poll_ids', 'used_as_default_projector_for_motion_poll_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_motion_poll_ids AFTER UPDATE OF used_as_default_projector_for_motion_poll_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_motion_poll_ids', 'used_as_default_projector_for_motion_poll_in_meeting_id');


-- definition trigger not null for meeting.default_projector_poll_ids against projectorT.used_as_default_projector_for_poll_in_meeting_id
CREATE CONSTRAINT TRIGGER tr_i_meeting_default_projector_poll_ids AFTER INSERT ON projectorT INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_poll_ids', 'used_as_default_projector_for_poll_in_meeting_id');

CREATE CONSTRAINT TRIGGER tr_ud_meeting_default_projector_poll_ids AFTER UPDATE OF used_as_default_projector_for_poll_in_meeting_id OR DELETE ON projectorT
FOR EACH ROW EXECUTE FUNCTION check_not_null_for_relation_lists('meeting', 'default_projector_poll_ids', 'used_as_default_projector_for_poll_in_meeting_id');



/*   Relation-list infos
Generated: What will be generated for left field
    FIELD: a usual Database field
    SQL: a sql-expression in a view
    ***: Error
Field Attributes:Field Attributes opposite side
    1: cardinality 1
    1G: cardinality 1 with generic-relation field
    n: cardinality n
    nG: cardinality n with generic-relation-list field
    t: "to" defined
    r: "reference" defined
    s: sql directive inclusive sql-statement
    R: Required
Model.Field -> Model.Field
    model.field names
*/

/*
*** nrs: => organization/committee_ids:-> committee/
    Field with reference temporarely needs also to-attribute
SQL nt:1r => organization/active_meeting_ids:-> meeting/is_active_in_organization_id
SQL nt:1r => organization/archived_meeting_ids:-> meeting/is_archived_in_organization_id
SQL nt:1r => organization/template_meeting_ids:-> meeting/template_for_organization_id
*** nr: => organization/organization_tag_ids:-> organization_tag/
    Field with reference temporarely needs also to-attribute
*** 1rR: => organization/theme_id:-> theme/
    Field with reference temporarely needs also to-attribute
*** nr: => organization/theme_ids:-> theme/
    Field with reference temporarely needs also to-attribute
SQL nt:1GrR => organization/mediafile_ids:-> mediafile/owner_id
*** nr: => organization/user_ids:-> user/
    Field with reference temporarely needs also to-attribute

SQL nt:nt => user/is_present_in_meeting_ids:-> meeting/present_user_ids
SQL nt:nt => user/committee_management_ids:-> committee/manager_ids
SQL nt:1r => user/forwarding_committee_ids:-> committee/forwarding_user_id
SQL nt:1rR => user/meeting_user_ids:-> meeting_user/user_id
SQL nt:nt => user/poll_voted_ids:-> poll/voted_ids
SQL nt:1Gr => user/option_ids:-> option/content_object_id
SQL nt:1r => user/vote_ids:-> vote/user_id
SQL nt:1r => user/delegated_vote_ids:-> vote/delegated_user_id
SQL nt:1r => user/poll_candidate_ids:-> poll_candidate/user_id

FIELD 1rR: => meeting_user/user_id:-> user/
FIELD 1rR: => meeting_user/meeting_id:-> meeting/
SQL nt:1rR => meeting_user/personal_note_ids:-> personal_note/meeting_user_id
SQL nt:1r => meeting_user/speaker_ids:-> speaker/meeting_user_id
SQL nt:nt => meeting_user/supported_motion_ids:-> motion/supporter_meeting_user_ids
SQL nt:1rR => meeting_user/motion_editor_ids:-> motion_editor/meeting_user_id
SQL nt:1rR => meeting_user/motion_working_group_speaker_ids:-> motion_working_group_speaker/meeting_user_id
SQL nt:1rR => meeting_user/motion_submitter_ids:-> motion_submitter/meeting_user_id
SQL nt:1r => meeting_user/assignment_candidate_ids:-> assignment_candidate/meeting_user_id
FIELD 1r: => meeting_user/vote_delegated_to_id:-> meeting_user/
SQL nt:1r => meeting_user/vote_delegations_from_ids:-> meeting_user/vote_delegated_to_id
SQL nt:1rR => meeting_user/chat_message_ids:-> chat_message/meeting_user_id
SQL nt:nt => meeting_user/group_ids:-> group/meeting_user_ids
SQL nt:nt => meeting_user/structure_level_ids:-> structure_level/meeting_user_ids

SQL nGt:nt,nt => organization_tag/tagged_ids:-> committee/organization_tag_ids,meeting/organization_tag_ids

*** 1t:1rR => theme/theme_for_organization_id:-> organization/theme_id
    Field with reference temporarely needs also to-attribute

SQL nt:1rR => committee/meeting_ids:-> meeting/committee_id
*** 1r: => committee/default_meeting_id:-> meeting/
    Field with reference temporarely needs also to-attribute
SQL nt:nt => committee/manager_ids:-> user/committee_management_ids
SQL nt:nt => committee/forward_to_committee_ids:-> committee/receive_forwardings_from_committee_ids
SQL nt:nt => committee/receive_forwardings_from_committee_ids:-> committee/forward_to_committee_ids
FIELD 1r: => committee/forwarding_user_id:-> user/
SQL nt:nGt => committee/organization_tag_ids:-> organization_tag/tagged_ids

FIELD 1r: => meeting/is_active_in_organization_id:-> organization/
FIELD 1r: => meeting/is_archived_in_organization_id:-> organization/
FIELD 1r: => meeting/template_for_organization_id:-> organization/
FIELD 1rR: => meeting/motions_default_workflow_id:-> motion_workflow/
FIELD 1rR: => meeting/motions_default_amendment_workflow_id:-> motion_workflow/
FIELD 1rR: => meeting/motions_default_statute_amendment_workflow_id:-> motion_workflow/
SQL nt:1r => meeting/motion_poll_default_group_ids:-> group/used_as_motion_poll_default_id
SQL nt:1rR => meeting/poll_candidate_list_ids:-> poll_candidate_list/meeting_id
SQL nt:1rR => meeting/poll_candidate_ids:-> poll_candidate/meeting_id
SQL nt:1rR => meeting/meeting_user_ids:-> meeting_user/meeting_id
SQL nt:1r => meeting/assignment_poll_default_group_ids:-> group/used_as_assignment_poll_default_id
SQL nt:1r => meeting/poll_default_group_ids:-> group/used_as_poll_default_id
SQL nt:1r => meeting/topic_poll_default_group_ids:-> group/used_as_topic_poll_default_id
SQL nt:1rR => meeting/projector_ids:-> projector/meeting_id
SQL nt:1rR => meeting/all_projection_ids:-> projection/meeting_id
SQL nt:1rR => meeting/projector_message_ids:-> projector_message/meeting_id
SQL nt:1rR => meeting/projector_countdown_ids:-> projector_countdown/meeting_id
SQL nt:1rR => meeting/tag_ids:-> tag/meeting_id
SQL nt:1rR => meeting/agenda_item_ids:-> agenda_item/meeting_id
SQL nt:1rR => meeting/list_of_speakers_ids:-> list_of_speakers/meeting_id
SQL nt:1rR => meeting/structure_level_list_of_speakers_ids:-> structure_level_list_of_speakers/meeting_id
SQL nt:1rR => meeting/point_of_order_category_ids:-> point_of_order_category/meeting_id
SQL nt:1rR => meeting/speaker_ids:-> speaker/meeting_id
SQL nt:1rR => meeting/topic_ids:-> topic/meeting_id
SQL nt:1rR => meeting/group_ids:-> group/meeting_id
SQL nt:1GrR => meeting/mediafile_ids:-> mediafile/owner_id
SQL nt:1rR => meeting/motion_ids:-> motion/meeting_id
SQL nt:1r => meeting/forwarded_motion_ids:-> motion/origin_meeting_id
SQL nt:1rR => meeting/motion_comment_section_ids:-> motion_comment_section/meeting_id
SQL nt:1rR => meeting/motion_category_ids:-> motion_category/meeting_id
SQL nt:1rR => meeting/motion_block_ids:-> motion_block/meeting_id
SQL nt:1rR => meeting/motion_workflow_ids:-> motion_workflow/meeting_id
SQL nt:1rR => meeting/motion_statute_paragraph_ids:-> motion_statute_paragraph/meeting_id
SQL nt:1rR => meeting/motion_comment_ids:-> motion_comment/meeting_id
SQL nt:1rR => meeting/motion_submitter_ids:-> motion_submitter/meeting_id
SQL nt:1rR => meeting/motion_editor_ids:-> motion_editor/meeting_id
SQL nt:1rR => meeting/motion_working_group_speaker_ids:-> motion_working_group_speaker/meeting_id
SQL nt:1rR => meeting/motion_change_recommendation_ids:-> motion_change_recommendation/meeting_id
SQL nt:1rR => meeting/motion_state_ids:-> motion_state/meeting_id
SQL nt:1rR => meeting/poll_ids:-> poll/meeting_id
SQL nt:1rR => meeting/option_ids:-> option/meeting_id
SQL nt:1rR => meeting/vote_ids:-> vote/meeting_id
SQL nt:1rR => meeting/assignment_ids:-> assignment/meeting_id
SQL nt:1rR => meeting/assignment_candidate_ids:-> assignment_candidate/meeting_id
SQL nt:1rR => meeting/personal_note_ids:-> personal_note/meeting_id
SQL nt:1rR => meeting/chat_group_ids:-> chat_group/meeting_id
SQL nt:1rR => meeting/chat_message_ids:-> chat_message/meeting_id
SQL nt:1rR => meeting/structure_level_ids:-> structure_level/meeting_id
*** 1r: => meeting/logo_projector_main_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/logo_projector_header_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/logo_web_header_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/logo_pdf_header_l_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/logo_pdf_header_r_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/logo_pdf_footer_l_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/logo_pdf_footer_r_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/logo_pdf_ballot_paper_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/font_regular_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/font_italic_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/font_bold_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/font_bold_italic_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/font_monospace_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/font_chyron_speaker_name_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/font_projector_h1_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/font_projector_h2_id:-> mediafile/
    Field with reference temporarely needs also to-attribute
FIELD 1rR: => meeting/committee_id:-> committee/
*** 1t:1r => meeting/default_meeting_for_committee_id:-> committee/default_meeting_id
    Field with reference temporarely needs also to-attribute
SQL nt:nGt => meeting/organization_tag_ids:-> organization_tag/tagged_ids
SQL nt:nt => meeting/present_user_ids:-> user/is_present_in_meeting_ids
FIELD 1rR: => meeting/reference_projector_id:-> projector/
*** 1r: => meeting/list_of_speakers_countdown_id:-> projector_countdown/
    Field with reference temporarely needs also to-attribute
*** 1r: => meeting/poll_countdown_id:-> projector_countdown/
    Field with reference temporarely needs also to-attribute
SQL nt:1GrR => meeting/projection_ids:-> projection/content_object_id
SQL ntR:1r => meeting/default_projector_agenda_item_list_ids:-> projector/used_as_default_projector_for_agenda_item_list_in_meeting_id
SQL ntR:1r => meeting/default_projector_topic_ids:-> projector/used_as_default_projector_for_topic_in_meeting_id
SQL ntR:1r => meeting/default_projector_list_of_speakers_ids:-> projector/used_as_default_projector_for_list_of_speakers_in_meeting_id
SQL ntR:1r => meeting/default_projector_current_list_of_speakers_ids:-> projector/used_as_default_projector_for_current_los_in_meeting_id
SQL ntR:1r => meeting/default_projector_motion_ids:-> projector/used_as_default_projector_for_motion_in_meeting_id
SQL ntR:1r => meeting/default_projector_amendment_ids:-> projector/used_as_default_projector_for_amendment_in_meeting_id
SQL ntR:1r => meeting/default_projector_motion_block_ids:-> projector/used_as_default_projector_for_motion_block_in_meeting_id
SQL ntR:1r => meeting/default_projector_assignment_ids:-> projector/used_as_default_projector_for_assignment_in_meeting_id
SQL ntR:1r => meeting/default_projector_mediafile_ids:-> projector/used_as_default_projector_for_mediafile_in_meeting_id
SQL ntR:1r => meeting/default_projector_message_ids:-> projector/used_as_default_projector_for_message_in_meeting_id
SQL ntR:1r => meeting/default_projector_countdown_ids:-> projector/used_as_default_projector_for_countdown_in_meeting_id
SQL ntR:1r => meeting/default_projector_assignment_poll_ids:-> projector/used_as_default_projector_for_assignment_poll_in_meeting_id
SQL ntR:1r => meeting/default_projector_motion_poll_ids:-> projector/used_as_default_projector_for_motion_poll_in_meeting_id
SQL ntR:1r => meeting/default_projector_poll_ids:-> projector/used_as_default_projector_for_poll_in_meeting_id
FIELD 1rR: => meeting/default_group_id:-> group/
*** 1r: => meeting/admin_group_id:-> group/
    Field with reference temporarely needs also to-attribute

SQL nt:nt => structure_level/meeting_user_ids:-> meeting_user/structure_level_ids
SQL nt:1rR => structure_level/structure_level_list_of_speakers_ids:-> structure_level_list_of_speakers/structure_level_id
FIELD 1rR: => structure_level/meeting_id:-> meeting/

SQL nt:nt => group/meeting_user_ids:-> meeting_user/group_ids
SQL 1t:1rR => group/default_group_for_meeting_id:-> meeting/default_group_id
*** 1t:1r => group/admin_group_for_meeting_id:-> meeting/admin_group_id
    Field with reference temporarely needs also to-attribute
SQL nt:nt => group/mediafile_access_group_ids:-> mediafile/access_group_ids
SQL nt:nt => group/mediafile_inherited_access_group_ids:-> mediafile/inherited_access_group_ids
SQL nt:nt => group/read_comment_section_ids:-> motion_comment_section/read_group_ids
SQL nt:nt => group/write_comment_section_ids:-> motion_comment_section/write_group_ids
SQL nt:nt => group/read_chat_group_ids:-> chat_group/read_group_ids
SQL nt:nt => group/write_chat_group_ids:-> chat_group/write_group_ids
SQL nt:nt => group/poll_ids:-> poll/entitled_group_ids
FIELD 1r: => group/used_as_motion_poll_default_id:-> meeting/
FIELD 1r: => group/used_as_assignment_poll_default_id:-> meeting/
FIELD 1r: => group/used_as_topic_poll_default_id:-> meeting/
FIELD 1r: => group/used_as_poll_default_id:-> meeting/
FIELD 1rR: => group/meeting_id:-> meeting/

FIELD 1rR: => personal_note/meeting_user_id:-> meeting_user/
FIELD 1Gr: => personal_note/content_object_id:-> motion/
FIELD 1rR: => personal_note/meeting_id:-> meeting/

SQL nGt:nt,nt,nt => tag/tagged_ids:-> agenda_item/tag_ids,assignment/tag_ids,motion/tag_ids
FIELD 1rR: => tag/meeting_id:-> meeting/

FIELD 1GrR:,,, => agenda_item/content_object_id:-> motion/,motion_block/,assignment/,topic/
FIELD 1r: => agenda_item/parent_id:-> agenda_item/
SQL nt:1r => agenda_item/child_ids:-> agenda_item/parent_id
SQL nt:nGt => agenda_item/tag_ids:-> tag/tagged_ids
SQL nt:1GrR => agenda_item/projection_ids:-> projection/content_object_id
FIELD 1rR: => agenda_item/meeting_id:-> meeting/

FIELD 1GrR:,,,, => list_of_speakers/content_object_id:-> motion/,motion_block/,assignment/,topic/,mediafile/
SQL nt:1rR => list_of_speakers/speaker_ids:-> speaker/list_of_speakers_id
SQL nt:1rR => list_of_speakers/structure_level_list_of_speakers_ids:-> structure_level_list_of_speakers/list_of_speakers_id
SQL nt:1GrR => list_of_speakers/projection_ids:-> projection/content_object_id
FIELD 1rR: => list_of_speakers/meeting_id:-> meeting/

FIELD 1rR: => structure_level_list_of_speakers/structure_level_id:-> structure_level/
FIELD 1rR: => structure_level_list_of_speakers/list_of_speakers_id:-> list_of_speakers/
SQL nt:1r => structure_level_list_of_speakers/speaker_ids:-> speaker/structure_level_list_of_speakers_id
FIELD 1rR: => structure_level_list_of_speakers/meeting_id:-> meeting/

FIELD 1rR: => point_of_order_category/meeting_id:-> meeting/
SQL nt:1r => point_of_order_category/speaker_ids:-> speaker/point_of_order_category_id

FIELD 1rR: => speaker/list_of_speakers_id:-> list_of_speakers/
FIELD 1r: => speaker/structure_level_list_of_speakers_id:-> structure_level_list_of_speakers/
FIELD 1r: => speaker/meeting_user_id:-> meeting_user/
FIELD 1r: => speaker/point_of_order_category_id:-> point_of_order_category/
FIELD 1rR: => speaker/meeting_id:-> meeting/

SQL nt:nGt => topic/attachment_ids:-> mediafile/attachment_ids
SQL 1tR:1GrR => topic/agenda_item_id:-> agenda_item/content_object_id
SQL 1tR:1GrR => topic/list_of_speakers_id:-> list_of_speakers/content_object_id
SQL nt:1GrR => topic/poll_ids:-> poll/content_object_id
SQL nt:1GrR => topic/projection_ids:-> projection/content_object_id
FIELD 1rR: => topic/meeting_id:-> meeting/

FIELD 1r: => motion/lead_motion_id:-> motion/
SQL nt:1r => motion/amendment_ids:-> motion/lead_motion_id
FIELD 1r: => motion/sort_parent_id:-> motion/
SQL nt:1r => motion/sort_child_ids:-> motion/sort_parent_id
FIELD 1r: => motion/origin_id:-> motion/
FIELD 1r: => motion/origin_meeting_id:-> meeting/
SQL nt:1r => motion/derived_motion_ids:-> motion/origin_id
SQL nt:nt => motion/all_origin_ids:-> motion/all_derived_motion_ids
SQL nt:nt => motion/all_derived_motion_ids:-> motion/all_origin_ids
FIELD 1rR: => motion/state_id:-> motion_state/
FIELD 1r: => motion/recommendation_id:-> motion_state/
SQL nGt:nt => motion/state_extension_reference_ids:-> motion/referenced_in_motion_state_extension_ids
SQL nt:nGt => motion/referenced_in_motion_state_extension_ids:-> motion/state_extension_reference_ids
SQL nGt:nt => motion/recommendation_extension_reference_ids:-> motion/referenced_in_motion_recommendation_extension_ids
SQL nt:nGt => motion/referenced_in_motion_recommendation_extension_ids:-> motion/recommendation_extension_reference_ids
FIELD 1r: => motion/category_id:-> motion_category/
FIELD 1r: => motion/block_id:-> motion_block/
SQL nt:1rR => motion/submitter_ids:-> motion_submitter/motion_id
SQL nt:nt => motion/supporter_meeting_user_ids:-> meeting_user/supported_motion_ids
SQL nt:1rR => motion/editor_ids:-> motion_editor/motion_id
SQL nt:1rR => motion/working_group_speaker_ids:-> motion_working_group_speaker/motion_id
SQL nt:1GrR => motion/poll_ids:-> poll/content_object_id
SQL nt:1Gr => motion/option_ids:-> option/content_object_id
SQL nt:1rR => motion/change_recommendation_ids:-> motion_change_recommendation/motion_id
FIELD 1r: => motion/statute_paragraph_id:-> motion_statute_paragraph/
SQL nt:1rR => motion/comment_ids:-> motion_comment/motion_id
SQL 1t:1GrR => motion/agenda_item_id:-> agenda_item/content_object_id
SQL 1tR:1GrR => motion/list_of_speakers_id:-> list_of_speakers/content_object_id
SQL nt:nGt => motion/tag_ids:-> tag/tagged_ids
SQL nt:nGt => motion/attachment_ids:-> mediafile/attachment_ids
SQL nt:1GrR => motion/projection_ids:-> projection/content_object_id
SQL nt:1Gr => motion/personal_note_ids:-> personal_note/content_object_id
FIELD 1rR: => motion/meeting_id:-> meeting/

FIELD 1rR: => motion_submitter/meeting_user_id:-> meeting_user/
FIELD 1rR: => motion_submitter/motion_id:-> motion/
FIELD 1rR: => motion_submitter/meeting_id:-> meeting/

FIELD 1rR: => motion_editor/meeting_user_id:-> meeting_user/
FIELD 1rR: => motion_editor/motion_id:-> motion/
FIELD 1rR: => motion_editor/meeting_id:-> meeting/

FIELD 1rR: => motion_working_group_speaker/meeting_user_id:-> meeting_user/
FIELD 1rR: => motion_working_group_speaker/motion_id:-> motion/
FIELD 1rR: => motion_working_group_speaker/meeting_id:-> meeting/

FIELD 1rR: => motion_comment/motion_id:-> motion/
FIELD 1rR: => motion_comment/section_id:-> motion_comment_section/
FIELD 1rR: => motion_comment/meeting_id:-> meeting/

SQL nt:1rR => motion_comment_section/comment_ids:-> motion_comment/section_id
SQL nt:nt => motion_comment_section/read_group_ids:-> group/read_comment_section_ids
SQL nt:nt => motion_comment_section/write_group_ids:-> group/write_comment_section_ids
FIELD 1rR: => motion_comment_section/meeting_id:-> meeting/

FIELD 1r: => motion_category/parent_id:-> motion_category/
SQL nt:1r => motion_category/child_ids:-> motion_category/parent_id
SQL nt:1r => motion_category/motion_ids:-> motion/category_id
FIELD 1rR: => motion_category/meeting_id:-> meeting/

SQL nt:1r => motion_block/motion_ids:-> motion/block_id
SQL 1t:1GrR => motion_block/agenda_item_id:-> agenda_item/content_object_id
SQL 1tR:1GrR => motion_block/list_of_speakers_id:-> list_of_speakers/content_object_id
SQL nt:1GrR => motion_block/projection_ids:-> projection/content_object_id
FIELD 1rR: => motion_block/meeting_id:-> meeting/

FIELD 1rR: => motion_change_recommendation/motion_id:-> motion/
FIELD 1rR: => motion_change_recommendation/meeting_id:-> meeting/

FIELD 1r: => motion_state/submitter_withdraw_state_id:-> motion_state/
SQL nt:1r => motion_state/submitter_withdraw_back_ids:-> motion_state/submitter_withdraw_state_id
SQL nt:nt => motion_state/next_state_ids:-> motion_state/previous_state_ids
SQL nt:nt => motion_state/previous_state_ids:-> motion_state/next_state_ids
SQL nt:1rR => motion_state/motion_ids:-> motion/state_id
SQL nt:1r => motion_state/motion_recommendation_ids:-> motion/recommendation_id
FIELD 1rR: => motion_state/workflow_id:-> motion_workflow/
SQL 1t:1rR => motion_state/first_state_of_workflow_id:-> motion_workflow/first_state_id
FIELD 1rR: => motion_state/meeting_id:-> meeting/

SQL nt:1rR => motion_workflow/state_ids:-> motion_state/workflow_id
FIELD 1rR: => motion_workflow/first_state_id:-> motion_state/
SQL 1t:1rR => motion_workflow/default_workflow_meeting_id:-> meeting/motions_default_workflow_id
SQL 1t:1rR => motion_workflow/default_amendment_workflow_meeting_id:-> meeting/motions_default_amendment_workflow_id
SQL 1t:1rR => motion_workflow/default_statute_amendment_workflow_meeting_id:-> meeting/motions_default_statute_amendment_workflow_id
FIELD 1rR: => motion_workflow/meeting_id:-> meeting/

SQL nt:1r => motion_statute_paragraph/motion_ids:-> motion/statute_paragraph_id
FIELD 1rR: => motion_statute_paragraph/meeting_id:-> meeting/

FIELD 1GrR:,, => poll/content_object_id:-> motion/,assignment/,topic/
SQL nt:1r => poll/option_ids:-> option/poll_id
*** 1r: => poll/global_option_id:-> option/
    Field with reference temporarely needs also to-attribute
SQL nt:nt => poll/voted_ids:-> user/poll_voted_ids
SQL nt:nt => poll/entitled_group_ids:-> group/poll_ids
SQL nt:1GrR => poll/projection_ids:-> projection/content_object_id
FIELD 1rR: => poll/meeting_id:-> meeting/

FIELD 1r: => option/poll_id:-> poll/
*** 1t:1r => option/used_as_global_option_in_poll_id:-> poll/global_option_id
    Field with reference temporarely needs also to-attribute
SQL nt:1rR => option/vote_ids:-> vote/option_id
FIELD 1Gr:,, => option/content_object_id:-> motion/,user/,poll_candidate_list/
FIELD 1rR: => option/meeting_id:-> meeting/

FIELD 1rR: => vote/option_id:-> option/
FIELD 1r: => vote/user_id:-> user/
FIELD 1r: => vote/delegated_user_id:-> user/
FIELD 1rR: => vote/meeting_id:-> meeting/

SQL nt:1rR => assignment/candidate_ids:-> assignment_candidate/assignment_id
SQL nt:1GrR => assignment/poll_ids:-> poll/content_object_id
SQL 1t:1GrR => assignment/agenda_item_id:-> agenda_item/content_object_id
SQL 1tR:1GrR => assignment/list_of_speakers_id:-> list_of_speakers/content_object_id
SQL nt:nGt => assignment/tag_ids:-> tag/tagged_ids
SQL nt:nGt => assignment/attachment_ids:-> mediafile/attachment_ids
SQL nt:1GrR => assignment/projection_ids:-> projection/content_object_id
FIELD 1rR: => assignment/meeting_id:-> meeting/

FIELD 1rR: => assignment_candidate/assignment_id:-> assignment/
FIELD 1r: => assignment_candidate/meeting_user_id:-> meeting_user/
FIELD 1rR: => assignment_candidate/meeting_id:-> meeting/

SQL nt:1rR => poll_candidate_list/poll_candidate_ids:-> poll_candidate/poll_candidate_list_id
FIELD 1rR: => poll_candidate_list/meeting_id:-> meeting/
SQL 1tR:1Gr => poll_candidate_list/option_id:-> option/content_object_id

FIELD 1rR: => poll_candidate/poll_candidate_list_id:-> poll_candidate_list/
FIELD 1r: => poll_candidate/user_id:-> user/
FIELD 1rR: => poll_candidate/meeting_id:-> meeting/

SQL nt:nt => mediafile/inherited_access_group_ids:-> group/mediafile_inherited_access_group_ids
SQL nt:nt => mediafile/access_group_ids:-> group/mediafile_access_group_ids
FIELD 1r: => mediafile/parent_id:-> mediafile/
SQL nt:1r => mediafile/child_ids:-> mediafile/parent_id
SQL 1t:1GrR => mediafile/list_of_speakers_id:-> list_of_speakers/content_object_id
SQL nt:1GrR => mediafile/projection_ids:-> projection/content_object_id
SQL nGt:nt,nt,nt => mediafile/attachment_ids:-> motion/attachment_ids,topic/attachment_ids,assignment/attachment_ids
FIELD 1GrR:, => mediafile/owner_id:-> meeting/,organization/
*** 1t:1r => mediafile/used_as_logo_projector_main_in_meeting_id:-> meeting/logo_projector_main_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_logo_projector_header_in_meeting_id:-> meeting/logo_projector_header_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_logo_web_header_in_meeting_id:-> meeting/logo_web_header_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_logo_pdf_header_l_in_meeting_id:-> meeting/logo_pdf_header_l_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_logo_pdf_header_r_in_meeting_id:-> meeting/logo_pdf_header_r_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_logo_pdf_footer_l_in_meeting_id:-> meeting/logo_pdf_footer_l_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_logo_pdf_footer_r_in_meeting_id:-> meeting/logo_pdf_footer_r_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_logo_pdf_ballot_paper_in_meeting_id:-> meeting/logo_pdf_ballot_paper_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_font_regular_in_meeting_id:-> meeting/font_regular_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_font_italic_in_meeting_id:-> meeting/font_italic_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_font_bold_in_meeting_id:-> meeting/font_bold_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_font_bold_italic_in_meeting_id:-> meeting/font_bold_italic_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_font_monospace_in_meeting_id:-> meeting/font_monospace_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_font_chyron_speaker_name_in_meeting_id:-> meeting/font_chyron_speaker_name_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_font_projector_h1_in_meeting_id:-> meeting/font_projector_h1_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => mediafile/used_as_font_projector_h2_in_meeting_id:-> meeting/font_projector_h2_id
    Field with reference temporarely needs also to-attribute

SQL nt:1r => projector/current_projection_ids:-> projection/current_projector_id
SQL nt:1r => projector/preview_projection_ids:-> projection/preview_projector_id
SQL nt:1r => projector/history_projection_ids:-> projection/history_projector_id
SQL 1t:1rR => projector/used_as_reference_projector_meeting_id:-> meeting/reference_projector_id
FIELD 1r: => projector/used_as_default_projector_for_agenda_item_list_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_topic_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_list_of_speakers_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_current_los_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_motion_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_amendment_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_motion_block_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_assignment_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_mediafile_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_message_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_countdown_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_assignment_poll_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_motion_poll_in_meeting_id:-> meeting/
FIELD 1r: => projector/used_as_default_projector_for_poll_in_meeting_id:-> meeting/
FIELD 1rR: => projector/meeting_id:-> meeting/

FIELD 1r: => projection/current_projector_id:-> projector/
FIELD 1r: => projection/preview_projector_id:-> projector/
FIELD 1r: => projection/history_projector_id:-> projector/
FIELD 1GrR:,,,,,,,,,, => projection/content_object_id:-> meeting/,motion/,mediafile/,list_of_speakers/,motion_block/,assignment/,agenda_item/,topic/,poll/,projector_message/,projector_countdown/
FIELD 1rR: => projection/meeting_id:-> meeting/

SQL nt:1GrR => projector_message/projection_ids:-> projection/content_object_id
FIELD 1rR: => projector_message/meeting_id:-> meeting/

SQL nt:1GrR => projector_countdown/projection_ids:-> projection/content_object_id
*** 1t:1r => projector_countdown/used_as_list_of_speakers_countdown_meeting_id:-> meeting/list_of_speakers_countdown_id
    Field with reference temporarely needs also to-attribute
*** 1t:1r => projector_countdown/used_as_poll_countdown_meeting_id:-> meeting/poll_countdown_id
    Field with reference temporarely needs also to-attribute
FIELD 1rR: => projector_countdown/meeting_id:-> meeting/

SQL nt:1rR => chat_group/chat_message_ids:-> chat_message/chat_group_id
SQL nt:nt => chat_group/read_group_ids:-> group/read_chat_group_ids
SQL nt:nt => chat_group/write_group_ids:-> group/write_chat_group_ids
FIELD 1rR: => chat_group/meeting_id:-> meeting/

FIELD 1rR: => chat_message/meeting_user_id:-> meeting_user/
FIELD 1rR: => chat_message/chat_group_id:-> chat_group/
FIELD 1rR: => chat_message/meeting_id:-> meeting/

*/

/*   Missing attribute handling for constant, sql, on_delete, equal_fields, unique, deferred */