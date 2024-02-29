import os
from datetime import datetime
from typing import Any
from unittest import TestCase

import psycopg
import pytest
from psycopg import sql
from psycopg.types.json import Jsonb
from src.db_utils import DbUtils

# ADMIN_USERNAME = "admin"
# ADMIN_PASSWORD = "admin"

class BaseTestCase(TestCase):
    temporary_template_db = "openslides_template"
    work_on_test_db = "openslides_test"
    db_connection: psycopg.Connection = None

    @classmethod
    def set_db_connection(cls, db_name:str, autocommit:bool = False, row_factory:callable = psycopg.rows.dict_row) -> None:
        env = os.environ
        try:
            cls.db_connection = psycopg.connect(f"dbname='{db_name}' user='{env['POSTGRES_USER']}' host='{env['POSTGRES_HOST']}' password='{env['PGPASSWORD']}'", autocommit=autocommit, row_factory=row_factory)
        except Exception as e:
            raise Exception(f"Cannot connect to postgres: {e.message}")

    @classmethod
    def setup_class(cls):
        env = os.environ
        cls.set_db_connection("postgres", True)
        with cls.db_connection:
            with cls.db_connection.cursor() as curs:
                curs.execute(
                    sql.SQL("DROP DATABASE IF EXISTS {temporary_template_db} (FORCE);").format(
                        temporary_template_db=sql.Identifier(cls.temporary_template_db)
                    )
                )
                curs.execute(
                    sql.SQL("CREATE DATABASE {db_to_create} TEMPLATE {template_db};").format(
                        db_to_create=sql.Identifier(cls.temporary_template_db),
                        template_db=sql.Identifier(env['POSTGRES_DB'])))
        cls.set_db_connection(cls.temporary_template_db)
        with cls.db_connection:
            cls.populate_database()

    @classmethod
    def teardown_class(cls):
        """ remove last test db and drop the temporary template db"""
        cls.set_db_connection("postgres", True)
        with cls.db_connection:
            with cls.db_connection.cursor() as curs:
                curs.execute(sql.SQL("DROP DATABASE IF EXISTS {} (FORCE);").format(sql.Identifier(cls.work_on_test_db)))
                curs.execute(sql.SQL("DROP DATABASE IF EXISTS {} (FORCE);").format(sql.Identifier(cls.temporary_template_db)))

    def setUp(self) -> None:
        self.set_db_connection("postgres", autocommit=True)
        with self.db_connection:
            with self.db_connection.cursor() as curs:
                curs.execute(sql.SQL("DROP DATABASE IF EXISTS {} (FORCE);").format(sql.Identifier(self.work_on_test_db)))
                curs.execute(sql.SQL("CREATE DATABASE {test_db} TEMPLATE {temporary_template_db};").format(
                    test_db=sql.Identifier(self.work_on_test_db),
                    temporary_template_db=sql.Identifier(self.temporary_template_db)))

        self.set_db_connection(self.work_on_test_db)

    @classmethod
    def populate_database(cls) -> None:
        """ do something like setting initial_data.json"""
        with cls.db_connection.transaction():
            with cls.db_connection.cursor() as curs:
                theme_id = DbUtils.insert_wrapper(curs, "themeT", {
                    "name": "OpenSlides Blue",
                    "accent_500": int("0x2196f3", 16),
                    "primary_500": int("0x317796", 16),
                    "warn_500": int("0xf06400", 16),
                })
                organization_id = DbUtils.insert_wrapper(curs, "organizationT", {
                    "name": "Test Organization",
                    "legal_notice": "<a href=\"http://www.openslides.org\">OpenSlides</a> is a free web based presentation and assembly system for visualizing and controlling agenda, motions and elections of an assembly.",
                    "login_text": "Good Morning!",
                    "default_language": "en",
                    "genders": ["male", "female", "diverse", "non-binary"],
                    "enable_electronic_voting": True,
                    "enable_chat": True,
                    "reset_password_verbose_errors": True,
                    "limit_of_meetings": 0,
                    "limit_of_users": 0,
                    "theme_id": theme_id,
                    "users_email_sender": "OpenSlides",
                    "users_email_subject": "OpenSlides access data",
                    "users_email_body": "Dear {name},\n\nthis is your personal OpenSlides login:\n\n{url}\nUsername: {username}\nPassword: {password}\n\n\nThis email was generated automatically.",
                    "url": "https://example.com",
                    "saml_enabled": False,
                    "saml_login_button_text": "SAML Login",
                    "saml_attr_mapping": Jsonb({
                        "saml_id": "username",
                        "title": "title",
                        "first_name": "firstName",
                        "last_name": "lastName",
                        "email": "email",
                        "gender": "gender",
                        "pronoun": "pronoun",
                        "is_active": "is_active",
                        "is_physical_person": "is_person"
                    })
                })
                user_id = DbUtils.insert_wrapper(curs, "userT", {
                    "username": "admin",
                    "last_name": "Administrator",
                    "is_active": True,
                    "is_physical_person": True,
                    "password": "316af7b2ddc20ead599c38541fbe87e9a9e4e960d4017d6e59de188b41b2758flD5BVZAZ8jLy4nYW9iomHcnkXWkfk3PgBjeiTSxjGG7+fBjMBxsaS1vIiAMxYh+K38l0gDW4wcP+i8tgoc4UBg==",
                    "default_password": "admin",
                    "can_change_own_password": True,
                    "gender": "male",
                    "default_vote_weight": "1.000000",
                    "organization_management_level": "superadmin",
                })
                committee_id = DbUtils.insert_wrapper(curs, "committeeT", {
                    "name": "Default committee",
                    "description": "Add description here",
                })
                meeting_id = curs.execute("select nextval(pg_get_serial_sequence('meetingT', 'id')) as new_id;").fetchone()["new_id"]
                group_ids = DbUtils.insert_many_wrapper(curs, "groupT", [
                    {
                        "name": "Default",
                        "permissions": [
                            "agenda_item.can_see_internal",
                            "assignment.can_see",
                            "list_of_speakers.can_see",
                            "mediafile.can_see",
                            "meeting.can_see_frontpage",
                            "motion.can_see",
                            "projector.can_see",
                            "user.can_see"
                        ],
                        "weight": 1,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "Admin",
                        "permissions": [],
                        "weight": 2,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "Staff",
                        "permissions": [
                            "agenda_item.can_manage",
                            "assignment.can_manage",
                            "assignment.can_nominate_self",
                            "list_of_speakers.can_be_speaker",
                            "list_of_speakers.can_manage",
                            "mediafile.can_manage",
                            "meeting.can_see_frontpage",
                            "meeting.can_see_history",
                            "motion.can_manage",
                            "poll.can_manage",
                            "projector.can_manage",
                            "tag.can_manage",
                            "user.can_manage"
                        ],
                        "weight": 3,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "Committees",
                        "permissions": [
                            "agenda_item.can_see_internal",
                            "assignment.can_see",
                            "list_of_speakers.can_see",
                            "mediafile.can_see",
                            "meeting.can_see_frontpage",
                            "motion.can_create",
                            "motion.can_create_amendments",
                            "motion.can_support",
                            "projector.can_see",
                            "user.can_see"
                        ],
                        "weight": 4,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "Delegates",
                        "permissions": [
                            "agenda_item.can_see_internal",
                            "assignment.can_nominate_other",
                            "assignment.can_nominate_self",
                            "list_of_speakers.can_be_speaker",
                            "mediafile.can_see",
                            "meeting.can_see_autopilot",
                            "meeting.can_see_frontpage",
                            "motion.can_create",
                            "motion.can_create_amendments",
                            "motion.can_support",
                            "projector.can_see",
                            "user.can_see"
                        ],
                        "weight": 5,
                        "meeting_id": meeting_id
                    }
                ])
                projector_ids = DbUtils.insert_many_wrapper(curs, "projectorT", [
                    {
                        "name": "Default projector",
                        "is_internal": False,
                        "scale": 0,
                        "scroll": 0,
                        "width": 1220,
                        "aspect_ratio_numerator": 4,
                        "aspect_ratio_denominator": 3,
                        "color": int("0x000000", 16),
                        "background_color": int("0xffffff", 16),
                        "header_background_color": int("0x317796", 16),
                        "header_font_color": int("0xf5f5f5", 16),
                        "header_h1_color": int("0x317796", 16),
                        "chyron_background_color": int("0x317796", 16),
                        "chyron_font_color": int("0xffffff", 16),
                        "show_header_footer": True,
                        "show_title": True,
                        "show_logo": True,
                        "show_clock": True,
                        "sequential_number": 1,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "Nebenprojektor",
                        "is_internal": False,
                        "scale": 0,
                        "scroll": 0,
                        "width": 1024,
                        "aspect_ratio_numerator": 16,
                        "aspect_ratio_denominator": 9,
                        "color": int("0x000000", 16),
                        "background_color": int("0x888888", 16),
                        "header_background_color": int("0x317796", 16),
                        "header_font_color": int("0xf5f5f5", 16),
                        "header_h1_color": int("0x317796", 16),
                        "chyron_background_color": int("0x317796", 16),
                        "chyron_font_color": int("0xffffff", 16),
                        "show_header_footer": True,
                        "show_title": True,
                        "show_logo": True,
                        "show_clock": True,
                        "sequential_number": 2,
                        "meeting_id": meeting_id
                    }
                ])
                workflow_simple_id = curs.execute("select nextval(pg_get_serial_sequence('motion_workflowT', 'id')) as new_id;").fetchone()["new_id"]
                workflow_complex_id = curs.execute("select nextval(pg_get_serial_sequence('motion_workflowT', 'id')) as new_id;").fetchone()["new_id"]
                wf_simple_motion_state_ids = DbUtils.insert_many_wrapper(curs, "motion_stateT", [
                    {
                        "name": "submitted",
                        "weight": 1,
                        "css_class": "lightblue",
                        "allow_support": True,
                        "allow_create_poll": True,
                        "allow_submitter_edit": True,
                        "set_number": True,
                        "merge_amendment_into_final": "undefined",
                        "workflow_id": workflow_simple_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "set_workflow_timestamp": True,
                        "allow_motion_forwarding": True,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "accepted",
                        "weight": 2,
                        "recommendation_label": "Acceptance",
                        "css_class": "green",
                        "set_number": True,
                        "merge_amendment_into_final": "undefined",
                        "workflow_id": workflow_simple_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "set_workflow_timestamp": False,
                        "allow_motion_forwarding": True,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "rejected",
                        "weight": 3,
                        "recommendation_label": "Rejection",
                        "css_class": "red",
                        "set_number": True,
                        "merge_amendment_into_final": "undefined",
                        "workflow_id": workflow_simple_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "not decided",
                        "weight": 4,
                        "recommendation_label": "No decision",
                        "css_class": "grey",
                        "set_number": True,
                        "merge_amendment_into_final": "undefined",
                        "workflow_id": workflow_simple_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": meeting_id
                    },
                ])
                wf_simple_first_state_id = wf_simple_motion_state_ids[0]
                wf_complex_motion_state_ids = DbUtils.insert_many_wrapper(curs, "motion_stateT", [
                    {
                        "name": "in progress",
                        "weight": 5,
                        "css_class": "lightblue",
                        "set_number": False,
                        "allow_submitter_edit": True,
                        "merge_amendment_into_final": "undefined",
                        "workflow_id": workflow_complex_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "set_workflow_timestamp": True,
                        "allow_motion_forwarding": True,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "submitted",
                        "weight": 6,
                        "css_class": "lightblue",
                        "set_number": False,
                        "merge_amendment_into_final": "undefined",
                        "workflow_id": workflow_complex_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": True,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "permitted",
                        "weight": 7,
                        "recommendation_label": "Permission",
                        "css_class": "lightblue",
                        "set_number": True,
                        "merge_amendment_into_final": "undefined",
                        "workflow_id": workflow_complex_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": True,
                        "allow_support": False,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": 1
                    },
                    {
                        "name": "accepted",
                        "weight": 8,
                        "recommendation_label": "Acceptance",
                        "css_class": "green",
                        "set_number": True,
                        "merge_amendment_into_final": "do_merge",
                        "workflow_id": workflow_complex_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "rejected",
                        "weight": 9,
                        "recommendation_label": "Rejection",
                        "css_class": "red",
                        "set_number": True,
                        "merge_amendment_into_final": "do_not_merge",
                        "workflow_id": 2,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "withdrawn",
                        "weight": 10,
                        "css_class": "grey",
                        "set_number": True,
                        "merge_amendment_into_final": "do_not_merge",
                        "workflow_id": workflow_complex_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "adjourned",
                        "weight": 11,
                        "recommendation_label": "Adjournment",
                        "css_class": "grey",
                        "set_number": True,
                        "merge_amendment_into_final": "do_not_merge",
                        "workflow_id": workflow_complex_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "not concerned",
                        "weight": 12,
                        "recommendation_label": "No concernment",
                        "css_class": "grey",
                        "set_number": True,
                        "merge_amendment_into_final": "do_not_merge",
                        "workflow_id": workflow_complex_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "referred to committee",
                        "weight": 13,
                        "recommendation_label": "Referral to committee",
                        "css_class": "grey",
                        "set_number": True,
                        "merge_amendment_into_final": "do_not_merge",
                        "workflow_id": workflow_complex_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "needs review",
                        "weight": 14,
                        "css_class": "grey",
                        "set_number": True,
                        "merge_amendment_into_final": "do_not_merge",
                        "workflow_id": workflow_complex_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": meeting_id
                    },
                    {
                        "name": "rejected (not authorized)",
                        "weight": 15,
                        "recommendation_label": "Rejection (not authorized)",
                        "css_class": "grey",
                        "set_number": True,
                        "merge_amendment_into_final": "do_not_merge",
                        "workflow_id": workflow_complex_id,
                        "restrictions": [],
                        "show_state_extension_field": False,
                        "show_recommendation_extension_field": False,
                        "allow_submitter_edit": False,
                        "allow_create_poll": False,
                        "allow_support": False,
                        "allow_motion_forwarding": True,
                        "set_workflow_timestamp": False,
                        "meeting_id": 1
                    },
                ])
                wf_complex_first_state_id = wf_complex_motion_state_ids[0]

                DbUtils.insert_many_wrapper(curs, "nm_motion_state_next_state_ids_motion_stateT", 
                    [
                        {"next_state_id": 2, "previous_state_id": 1},
                        {"next_state_id": 3, "previous_state_id": 1},
                        {"next_state_id": 4, "previous_state_id": 1},
                        {"next_state_id": 6, "previous_state_id": 5},
                        {"next_state_id": 10, "previous_state_id": 5},
                        {"next_state_id": 7, "previous_state_id": 6},
                        {"next_state_id": 10, "previous_state_id": 6},
                        {"next_state_id": 15, "previous_state_id": 6},
                        {"next_state_id": 8, "previous_state_id": 7},
                        {"next_state_id": 9, "previous_state_id": 7},
                        {"next_state_id": 10, "previous_state_id": 7},
                        {"next_state_id": 11, "previous_state_id": 7},
                        {"next_state_id": 12, "previous_state_id": 7},
                        {"next_state_id": 13, "previous_state_id": 7},
                        {"next_state_id": 14, "previous_state_id": 7},
                    ], returning='')
                assert [workflow_simple_id, workflow_complex_id] == DbUtils.insert_many_wrapper(curs, "motion_workflowT",
                    [
                        {
                            "id": workflow_simple_id,
                            "name": "Simple Workflow",
                            "sequential_number": 1,
                            "first_state_id": wf_simple_first_state_id,
                            "meeting_id": 1
                        },
                        {
                            "id": workflow_complex_id,
                            "name": "Complex Workflow",
                            "sequential_number": 2,
                            "first_state_id": wf_complex_first_state_id,
                            "meeting_id": 1
                        }
                    ]
                )
                assert 1 == DbUtils.insert_wrapper(curs, "meetingT", {
                    "id": meeting_id,
                    "name": "OpenSlides Demo",
                    "is_active_in_organization_id": organization_id,
                    "language": "en",
                    "conference_los_restriction": True,
                    "agenda_number_prefix": "TOP",
                    "motions_default_workflow_id": workflow_simple_id,
                    "motions_default_amendment_workflow_id": workflow_complex_id,
                    "motions_default_statute_amendment_workflow_id": workflow_complex_id,
                    "motions_recommendations_by": "ABK",
                    "motions_statute_recommendations_by": "",
                    "motions_statutes_enabled": True,
                    "motions_amendments_of_amendments": True,
                    "motions_amendments_prefix": "-\u00c4",
                    "motions_supporters_min_amount": 1,
                    "motions_export_preamble": "",
                    "users_enable_presence_view": True,
                    "users_pdf_wlan_encryption": "",
                    "users_enable_vote_delegations": True,
                    "poll_ballot_paper_selection": "CUSTOM_NUMBER",
                    "poll_ballot_paper_number": 8,
                    "poll_sort_poll_result_by_votes": True,
                    "poll_default_type": "nominal",
                    "poll_default_method": "votes",
                    "poll_default_onehundred_percent_base": "valid",
                    "committee_id": committee_id,
                    "reference_projector_id": projector_ids[0],
                    # Fields still not generated, required relation_list not implemented
                    # "default_projector_agenda_item_list_ids": [projector_ids[0]],
                    # "default_projector_topic_ids": [projector_ids[0]],
                    # "default_projector_list_of_speakers_ids": [projector_ids[1]],
                    # "default_projector_current_list_of_speakers_ids": [projector_ids[1]],
                    # "default_projector_motion_ids": [projector_ids[0]],
                    # "default_projector_amendment_ids": [projector_ids[0]],
                    # "default_projector_motion_block_ids": [projector_ids[0]],
                    # "default_projector_assignment_ids": [projector_ids[0]],
                    # "default_projector_mediafile_ids": [projector_ids[0]],
                    # "default_projector_message_ids": [projector_ids[0]],
                    # "default_projector_countdown_ids": [projector_ids[0]],
                    # "default_projector_assignment_poll_ids": [projector_ids[0]],
                    # "default_projector_motion_poll_ids": [projector_ids[0]],
                    # "default_projector_poll_ids": [projector_ids[0]],
                    "default_group_id": group_ids[0],
                    "admin_group_id": group_ids[1]
                })
                curs.execute("UPDATE committeeT SET default_meeting_id = %s where id = %s;", (meeting_id, committee_id))
