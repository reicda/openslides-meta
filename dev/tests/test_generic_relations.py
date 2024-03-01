from datetime import datetime

import psycopg
import pytest
from psycopg import sql
from src.db_utils import DbUtils
from tests.base import BaseTestCase


class Relations(BaseTestCase):
    """
    Used symbols in names of test:
    1: cardinality 1
    1G: cardinality 1 with generic-relation field
    n: cardinality n
    nG: cardinality n with generic-relation-list field
    t: "to" defined
    r: "reference" defined
    s: sql directive given, but must be generated
    s+: sql directive inclusive sql-statement
    R: Required
    """

    """ 1:1 relation tests """
    """
    FIELD 1tR:1t => meeting/motions_default_workflow_id:-> motion_workflow/default_workflow_meeting_id
    FIELD 1tR:1t => meeting/motions_default_amendment_workflow_id:-> motion_workflow/default_amendment_workflow_meeting_id
    FIELD 1tR:1t => meeting/motions_default_statute_amendment_workflow_id:-> motion_workflow/default_statute_amendment_workflow_meeting_id

    SQL 1t:1r => meeting/default_meeting_for_committee_id:-> committee/default_meeting_id
    FIELD 1r: => committee/default_meeting_id:-> meeting/

    FIELD 1tR:1t => meeting/reference_projector_id:-> projector/used_as_reference_projector_meeting_id
    FIELD 1tR:1t => meeting/default_group_id:-> group/default_group_for_meeting_id
    FIELD 1tR:1t => motion_workflow/first_state_id:-> motion_state/first_state_of_workflow_id
    """
    def test_one_to_one_pre_populated_1rR_1t(self) -> None:
        with self.db_connection.cursor() as curs:
            organization_row = DbUtils.select_id_wrapper(curs, "organization", self.organization_id, ["theme_id"])
            assert organization_row["theme_id"] == self.theme1_id
            theme_row = DbUtils.select_id_wrapper(curs, "theme", self.theme1_id, ["theme_for_organization_id"])
            assert theme_row["theme_for_organization_id"] == self.organization_id

    def test_one_to_one_pre_populated_1r_1t(self) -> None:
        with self.db_connection.cursor() as curs:
            committee_row = DbUtils.select_id_wrapper(curs, "committee", self.committee1_id, ["default_meeting_id"])
            assert committee_row["default_meeting_id"] == self.meeting1_id
            meeting_row = DbUtils.select_id_wrapper(curs, "meeting", self.meeting1_id, ["default_meeting_for_committee_id"])
            assert meeting_row["default_meeting_for_committee_id"] == self.committee1_id

    def test_one_to_one_1tR_1t(self) -> None:
        with self.db_connection.cursor() as curs:
            # Prepopulated
            meeting_row = DbUtils.select_id_wrapper(curs, "meeting", self.meeting1_id, ["default_group_id"])
            old_default_group_id = meeting_row["default_group_id"]
            old_default_group_row = DbUtils.select_id_wrapper(curs, "group_", old_default_group_id, ["default_group_for_meeting_id"])
            assert old_default_group_row["default_group_for_meeting_id"] == self.meeting1_id
            # change default group
            with self.db_connection.transaction():
                group_delegate_row = curs.execute(sql.SQL("SELECT id, name, meeting_id, default_group_for_meeting_id FROM group_ where name = %s and meeting_id = %s;"), ("Delegates", self.meeting1_id)).fetchone()
                assert group_delegate_row["id"] == 5
                assert group_delegate_row["name"] == "Delegates"
                assert group_delegate_row["meeting_id"] == self.meeting1_id
                assert group_delegate_row["default_group_for_meeting_id"] == None
                curs.execute(sql.SQL("UPDATE meetingT SET default_group_id = %s where id = %s;"), (group_delegate_row["id"], self.meeting1_id))
            # assert new and old data
            meeting_row = DbUtils.select_id_wrapper(curs, "meeting", self.meeting1_id, ["default_group_id"])
            assert meeting_row["default_group_id"] == group_delegate_row["id"]
            new_default_group_row = DbUtils.select_id_wrapper(curs, "group_", group_delegate_row["id"], ["default_group_for_meeting_id"])
            assert new_default_group_row["default_group_for_meeting_id"] == self.meeting1_id
            old_default_group_row = DbUtils.select_id_wrapper(curs, "group_", old_default_group_id, ["default_group_for_meeting_id"])
            assert old_default_group_row["default_group_for_meeting_id"] == None

    """ 1:n relation tests """
    """ n:m relation tests """
    """ manual sqls tests"""
    """ all field type tests """

    """ generic-relation tests """
    def test_generic_1GT_1tR(self) -> None:
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                pcl_id = 2
                option_id = 3
                curs.execute("select setval(pg_get_serial_sequence('poll_candidate_listT', 'id'), %s);", (pcl_id,))
                assert pcl_id == DbUtils.insert_wrapper(curs, "poll_candidate_listT", {"id": pcl_id, "meeting_id": self.meeting1_id})
                curs.execute("select setval(pg_get_serial_sequence('optionT', 'id'), %s);", (option_id,))
                assert option_id == DbUtils.insert_wrapper(curs, "optionT", {"id": option_id, "content_object_id": (content_object_id := f"poll_candidate_list/{pcl_id}"), "meeting_id": self.meeting1_id})
            option_row = DbUtils.select_id_wrapper(curs, "option", option_id, ["id", "content_object_id", "content_object_id_poll_candidate_list_id", "content_object_id_user_id"])
            assert option_row["id"] == option_id
            assert option_row["content_object_id"] == content_object_id
            assert option_row["content_object_id_poll_candidate_list_id"] == pcl_id
            assert option_row["content_object_id_user_id"] == None

            pcl_row = DbUtils.select_id_wrapper(curs, "poll_candidate_list", pcl_id, ["id", "option_id",])
            assert pcl_row["id"] == pcl_id
            assert pcl_row["option_id"] == option_id

    def test_generic_1GT_nt(self) -> None:
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                option_id = 3
                curs.execute("select setval(pg_get_serial_sequence('poll_candidate_listT', 'id'), %s);", (option_id,))
                option_id == DbUtils.insert_wrapper(curs, "optionT", {"id": option_id, "content_object_id": (content_object_id := f"user/{self.user1_id}"), "meeting_id": self.meeting1_id})
            option_row = DbUtils.select_id_wrapper(curs, "option", option_id, ["id", "content_object_id", "content_object_id_user_id", "content_object_id_poll_candidate_list_id"])
            assert option_row["id"] == option_id
            assert option_row["content_object_id"] == content_object_id
            assert option_row["content_object_id_user_id"] == self.user1_id
            assert option_row["content_object_id_poll_candidate_list_id"] == None

            user_row = DbUtils.select_id_wrapper(curs, "user_", self.user1_id, ["username", "option_ids",])
            assert user_row["option_ids"] == [option_id]
            assert user_row["username"] == "admin"

    def test_generic_1GTR_1t(self) -> None:
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                mediafile_id = 2
                los_id = 3
                curs.execute("select setval(pg_get_serial_sequence('mediafileT', 'id'), %s);", (mediafile_id,))
                assert mediafile_id == DbUtils.insert_wrapper(curs, "mediafileT", {"id": mediafile_id, "is_public": True, "owner_id": f"meeting/{self.meeting1_id}"})
                curs.execute("select setval(pg_get_serial_sequence('list_of_speakersT', 'id'), %s);", (los_id,))
                assert los_id == DbUtils.insert_wrapper(curs, "list_of_speakersT", {"id": los_id, "content_object_id": (content_object_id := f"mediafile/{mediafile_id}"), "meeting_id": self.meeting1_id, "sequential_number": 28})
            los_row = DbUtils.select_id_wrapper(curs, "list_of_speakers", los_id, ["id", "content_object_id", "content_object_id_mediafile_id", "content_object_id_topic_id"])
            assert los_row["id"] == los_id
            assert los_row["content_object_id"] == content_object_id
            assert los_row["content_object_id_mediafile_id"] == mediafile_id
            assert los_row["content_object_id_topic_id"] == None

            mediafile_row = DbUtils.select_id_wrapper(curs, "mediafile", mediafile_id, ["id", "list_of_speakers_id", "owner_id"])
            assert mediafile_row["id"] == mediafile_id
            assert mediafile_row["list_of_speakers_id"] == los_id

    def test_generic_1GTR_1tR(self) -> None:
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                assignment_id = 2
                los_id = 3
                curs.execute("select setval(pg_get_serial_sequence('assignmentT', 'id'), %s);", (assignment_id,))
                assert assignment_id == DbUtils.insert_wrapper(curs, "assignmentT", {"id": assignment_id, "title": "I am an assignment", "sequential_number": 42, "meeting_id": self.meeting1_id})
                curs.execute("select setval(pg_get_serial_sequence('list_of_speakersT', 'id'), %s);", (los_id,))
                assert los_id == DbUtils.insert_wrapper(curs, "list_of_speakersT", {"id": los_id, "content_object_id": (content_object_id := f"assignment/{assignment_id}"), "meeting_id": self.meeting1_id, "sequential_number": 28})
            los_row = DbUtils.select_id_wrapper(curs, "list_of_speakers", los_id, ["id", "content_object_id", "content_object_id_assignment_id", "content_object_id_topic_id"])
            assert los_row["id"] == los_id
            assert los_row["content_object_id"] == content_object_id
            assert los_row["content_object_id_assignment_id"] == assignment_id
            assert los_row["content_object_id_topic_id"] == None

            assignment_row = DbUtils.select_id_wrapper(curs, "assignment", assignment_id, ["id", "list_of_speakers_id"])
            assert assignment_row["id"] == assignment_id
            assert assignment_row["list_of_speakers_id"] == los_id

    def test_generic_1GTR_nt(self) -> None:
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                DbUtils.insert_many_wrapper(curs, "mediafileT", [
                    {
                        "is_public": True,
                        "owner_id": f"meeting/{self.meeting1_id}"
                    },
                    {
                        "is_public": True,
                        "owner_id": f"organization/{self.organization_id}"
                    },
                    {
                        "is_public": True,
                        "owner_id": f"meeting/{self.meeting1_id}"
                    },
                    {
                        "is_public": True,
                        "owner_id": f"organization/{self.organization_id}"
                    },
                ])
            rows = DbUtils.select_id_wrapper(curs, "mediafile", field_names=["owner_id", "owner_id_meeting_id", "owner_id_organization_id"])
            expected_results = (("meeting/1", 1, None), ("organization/1", None, 1), ("meeting/1", 1, None), ("organization/1", None, 1))
            for i, row in enumerate (rows):
                assert tuple(row.values()) == expected_results[i]

            meeting_row = DbUtils.select_id_wrapper(curs, "meeting", self.meeting1_id, ["mediafile_ids"])
            assert meeting_row["mediafile_ids"] == [1, 3]
            organization_row = DbUtils.select_id_wrapper(curs, "organization", self.organization_id, ["mediafile_ids"])
            assert organization_row["mediafile_ids"] == [2, 4]

    def test_generic_1Gt_check_constraint_error(self) -> None:
        with pytest.raises(psycopg.DatabaseError) as e:
            with self.db_connection.cursor() as curs:
                with self.db_connection.transaction():
                    DbUtils.insert_wrapper(curs, "mediafileT", {
                            "is_public": True,
                            "owner_id": f"motion_state/{self.meeting1_id}"
                        })
        assert 'motion_state/1' in str(e)

    """ generic-relation-list tests """
    def test_generic_nGt_nt(self) -> None:
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                tag_ids = DbUtils.insert_many_wrapper(curs, "organization_tagT", [
                    {
                        "name": "Orga Tag 1",
                        "color": 0xffee13
                    },
                    {
                        "name": "Orga Tag 2",
                        "color": 0x12ee13
                    },
                    {
                        "name": "Orga Tag 3",
                        "color": 0x00ee13
                    },
                ])
                DbUtils.insert_many_wrapper(curs, "gm_organization_tag_tagged_idsT", [
                    {"organization_tag_id": tag_ids[0], "tagged_id": f"committee/{self.committee1_id}"},
                    {"organization_tag_id": tag_ids[0], "tagged_id": f"meeting/{self.meeting1_id}"},
                    {"organization_tag_id": tag_ids[1], "tagged_id": f"committee/{self.committee1_id}"},
                    {"organization_tag_id": tag_ids[2], "tagged_id": f"meeting/{self.meeting1_id}"},
                ])
            rows = DbUtils.select_id_wrapper(curs, "gm_organization_tag_tagged_idsT", field_names=["id", "organization_tag_id", "tagged_id", "tagged_id_committee_id", "tagged_id_meeting_id"])
            expected_results = ((1, 1, "committee/1", 1, None), (2, 1, "meeting/1", None, 1), (3, 2, "committee/1", 1, None), (4, 3, "meeting/1", None, 1))
            for i, row in enumerate (rows):
                assert tuple(row.values()) == expected_results[i]

            committee_row = DbUtils.select_id_wrapper(curs, "committee", self.committee1_id, ["organization_tag_ids"])
            assert committee_row["organization_tag_ids"] == [1, 2]
            meeting_row = DbUtils.select_id_wrapper(curs, "meeting", self.meeting1_id, ["organization_tag_ids"])
            assert meeting_row["organization_tag_ids"] == [1, 3]

    def test_generic_nGt_check_constraint_error(self) -> None:
        with pytest.raises(psycopg.DatabaseError) as e:
            with self.db_connection.cursor() as curs:
                with self.db_connection.transaction():
                    tag_id = DbUtils.insert_wrapper(curs, "organization_tagT", {"name": "Orga Tag 1", "color": 0xffee13})
                    DbUtils.insert_many_wrapper(curs, "gm_organization_tag_tagged_idsT", [
                        {"organization_tag_id": tag_id, "tagged_id": f"committee/{self.committee1_id}"},
                        {"organization_tag_id": tag_id, "tagged_id": f"motion_state/{self.meeting1_id}"},
                    ])
        assert 'motion_state/1' in str(e)

    def test_generic_nGt_unique_constraint_error(self) -> None:
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                tag_id = DbUtils.insert_wrapper(curs, "organization_tagT", {"name": "Orga Tag 1", "color": 0xffee13})
                DbUtils.insert_wrapper(curs, "gm_organization_tag_tagged_idsT", {"organization_tag_id": tag_id, "tagged_id": f"committee/{self.committee1_id}"})
            with pytest.raises(psycopg.DatabaseError) as e:
                with self.db_connection.transaction():
                    DbUtils.insert_wrapper(curs, "gm_organization_tag_tagged_idsT", {"organization_tag_id": tag_id, "tagged_id": f"committee/{self.committee1_id}"})
            assert 'duplicate key value violates unique constraint' in str(e)
