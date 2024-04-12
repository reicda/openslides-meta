from datetime import datetime
from typing import cast

import psycopg
import pytest
from psycopg import sql
from sql import Table
from sql.aggregate import *
from sql.conditionals import *
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

    # TODO: remove test, fiktiv test with 1r:1tR, test s.o, in der die meeting-Seite ein SQL hat
    # jetzt setze ich mal ein erequired auf der Meeting Seite. Was ist übrigens mit 1r:1rR
    def test_one_to_one_pre_populated_1r_1tR(self) -> None:
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
                group_staff_row = curs.execute(sql.SQL("SELECT id, name, meeting_id, default_group_for_meeting_id FROM group_ where name = %s and meeting_id = %s;"), ("Staff", self.meeting1_id)).fetchone()
                assert group_staff_row["id"] == self.groupM1_staff_id
                assert group_staff_row["name"] == "Staff"
                assert group_staff_row["meeting_id"] == self.meeting1_id
                assert group_staff_row["default_group_for_meeting_id"] == None
                curs.execute(sql.SQL("UPDATE meeting_t SET default_group_id = %s where id = %s;"), (group_staff_row["id"], self.meeting1_id))
            # assert new and old data
            meeting_row = DbUtils.select_id_wrapper(curs, "meeting", self.meeting1_id, ["default_group_id"])
            assert meeting_row["default_group_id"] == group_staff_row["id"]
            new_default_group_row = DbUtils.select_id_wrapper(curs, "group_", group_staff_row["id"], ["default_group_for_meeting_id"])
            assert new_default_group_row["default_group_for_meeting_id"] == self.meeting1_id
            old_default_group_row = DbUtils.select_id_wrapper(curs, "group_", old_default_group_id, ["default_group_for_meeting_id"])
            assert old_default_group_row["default_group_for_meeting_id"] == None

    """ 1:n relation tests with n-side NOT NULL """
    """ Test:motion_state.submitter_withdraw_back_ids: sql okay?"""
    def test_one_to_many_1t_ntR_update_error(self) -> None:
        """ update removes default projector => Exception"""
        with self.db_connection.cursor() as curs:
            with pytest.raises(psycopg.errors.RaiseException) as e:
                projector_id = curs.execute("SELECT id from projector where used_as_default_projector_for_topic_in_meeting_id = %s", (self.meeting1_id,)).fetchone()['id']
                with self.db_connection.transaction():
                    curs.execute(sql.SQL("UPDATE projector_t SET used_as_default_projector_for_topic_in_meeting_id = null where id = %s;"), (projector_id,))
        assert 'Exception: NOT NULL CONSTRAINT VIOLATED for meeting.default_projector_topic_ids' in str(e)

    def test_one_to_many_1t_ntR_update_okay(self) -> None:
        """ Update sets new default projector before 2nd removes old default projector"""
        with self.db_connection.cursor() as curs:
            projector_ids = curs.execute("SELECT id from projector where meeting_id = %s", (self.meeting1_id,)).fetchall()
            with self.db_connection.transaction():
                curs.execute(sql.SQL("UPDATE projector_t SET used_as_default_projector_for_topic_in_meeting_id = %s where id = %s;"), (self.meeting1_id, projector_ids[1]["id"]))
                curs.execute(sql.SQL("UPDATE projector_t SET used_as_default_projector_for_topic_in_meeting_id = null where id = %s;"), (projector_ids[0]["id"],))
            assert projector_ids[1]["id"] == DbUtils.select_id_wrapper(curs, 'meeting', self.meeting1_id, ['default_projector_topic_ids'])['default_projector_topic_ids'][0]

    def test_one_to_many_1t_ntR_update_wrong_update_sequence_error(self) -> None:
        """ first update removes the projector from meeting => Exception"""
        with self.db_connection.cursor() as curs:
            projector_ids = curs.execute("SELECT id from projector where used_as_default_projector_for_topic_in_meeting_id = %s", (self.meeting1_id,)).fetchall()
            with pytest.raises(psycopg.errors.RaiseException) as e:
                with self.db_connection.transaction():
                    curs.execute(sql.SQL("UPDATE projector_t SET used_as_default_projector_for_topic_in_meeting_id = null where id = %s;"), (projector_ids[0]["id"],))
                    curs.execute(sql.SQL("UPDATE projector_t SET used_as_default_projector_for_topic_in_meeting_id = %s where id = %s;"), (self.meeting1_id, projector_ids[1]["id"]))
        assert 'Exception: NOT NULL CONSTRAINT VIOLATED for meeting.default_projector_topic_ids' in str(e)

    def test_one_to_many_1t_ntR_delete_error(self) -> None:
        """ delete projector from meeting => Exception"""
        with self.db_connection.cursor() as curs:
            projector_id = curs.execute("SELECT id from projector where used_as_default_projector_for_topic_in_meeting_id = %s", (self.meeting1_id,)).fetchone()["id"]
            with pytest.raises(psycopg.errors.RaiseException) as e:
                with self.db_connection.transaction():
                    curs.execute(sql.SQL("DELETE FROM projector where id = %s;"), (projector_id,))
        assert 'Exception: NOT NULL CONSTRAINT VIOLATED' in str(e)

    def test_one_to_many_1t_ntR_delete_insert_okay(self) -> None:
        """ first insert, than delete old default projector from meeting => okay"""
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                projector = curs.execute("SELECT * from projector where used_as_default_projector_for_topic_in_meeting_id = %s", (self.meeting1_id,)).fetchone()
                field_list = ["meeting_id", "used_as_default_projector_for_agenda_item_list_in_meeting_id", "used_as_default_projector_for_topic_in_meeting_id", "used_as_default_projector_for_list_of_speakers_in_meeting_id", "used_as_default_projector_for_current_los_in_meeting_id", "used_as_default_projector_for_motion_in_meeting_id", "used_as_default_projector_for_amendment_in_meeting_id", "used_as_default_projector_for_motion_block_in_meeting_id", "used_as_default_projector_for_assignment_in_meeting_id", "used_as_default_projector_for_mediafile_in_meeting_id", "used_as_default_projector_for_message_in_meeting_id", "used_as_default_projector_for_countdown_in_meeting_id", "used_as_default_projector_for_assignment_poll_in_meeting_id", "used_as_default_projector_for_motion_poll_in_meeting_id", "used_as_default_projector_for_poll_in_meeting_id"]
                data = {fname: projector[fname] for fname in field_list}
                data["sequential_number"] = projector["sequential_number"] + 2
                new_projector_id = DbUtils.insert_wrapper(curs, "projector_t", data)
                curs.execute(sql.SQL("UPDATE meeting_t SET reference_projector_id = %s where id = %s;"), (new_projector_id, projector["meeting_id"]))
                curs.execute(sql.SQL("DELETE FROM projector where id = %s;"), (projector["id"],))
            assert new_projector_id == cast(dict, DbUtils.select_id_wrapper(curs, "meeting", projector["meeting_id"], ["default_projector_topic_ids"]))["default_projector_topic_ids"][0]

    """ n:m relation tests """
    """ manual sqls tests"""
    """ all field type tests """
    """ constraint tests """

    """ generic-relation tests """
    def test_generic_1GT_1tR(self) -> None:
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                pcl_id = 2
                option_id = 3
                curs.execute("select setval(pg_get_serial_sequence('poll_candidate_list_t', 'id'), %s);", (pcl_id,))
                assert pcl_id == DbUtils.insert_wrapper(curs, "poll_candidate_list_t", {"id": pcl_id, "meeting_id": self.meeting1_id})
                curs.execute("select setval(pg_get_serial_sequence('option_t', 'id'), %s);", (option_id,))
                assert option_id == DbUtils.insert_wrapper(curs, "option_t", {"id": option_id, "content_object_id": (content_object_id := f"poll_candidate_list/{pcl_id}"), "meeting_id": self.meeting1_id})
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
                curs.execute("select setval(pg_get_serial_sequence('poll_candidate_list_t', 'id'), %s);", (option_id,))
                option_id == DbUtils.insert_wrapper(curs, "option_t", {"id": option_id, "content_object_id": (content_object_id := f"user/{self.user1_id}"), "meeting_id": self.meeting1_id})
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
                curs.execute("select setval(pg_get_serial_sequence('mediafile_t', 'id'), %s);", (mediafile_id,))
                assert mediafile_id == DbUtils.insert_wrapper(curs, "mediafile_t", {"id": mediafile_id, "is_public": True, "owner_id": f"meeting/{self.meeting1_id}"})
                curs.execute("select setval(pg_get_serial_sequence('list_of_speakers_t', 'id'), %s);", (los_id,))
                assert los_id == DbUtils.insert_wrapper(curs, "list_of_speakers_t", {"id": los_id, "content_object_id": (content_object_id := f"mediafile/{mediafile_id}"), "meeting_id": self.meeting1_id, "sequential_number": 28})
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
                curs.execute("select setval(pg_get_serial_sequence('assignment_t', 'id'), %s);", (assignment_id,))
                assert assignment_id == DbUtils.insert_wrapper(curs, "assignment_t", {"id": assignment_id, "title": "I am an assignment", "sequential_number": 42, "meeting_id": self.meeting1_id})
                curs.execute("select setval(pg_get_serial_sequence('list_of_speakers_t', 'id'), %s);", (los_id,))
                assert los_id == DbUtils.insert_wrapper(curs, "list_of_speakers_t", {"id": los_id, "content_object_id": (content_object_id := f"assignment/{assignment_id}"), "meeting_id": self.meeting1_id, "sequential_number": 28})
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
                DbUtils.insert_many_wrapper(curs, "mediafile_t", [
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
                    DbUtils.insert_wrapper(curs, "mediafile_t", {
                            "is_public": True,
                            "owner_id": f"motion_state/{self.meeting1_id}"
                        })
        assert 'motion_state/1' in str(e)

    """ generic-relation-list tests """
    def test_generic_nGt_nt(self) -> None:
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                tag_ids = DbUtils.insert_many_wrapper(curs, "organization_tag_t", [
                    {
                        "name": "Orga Tag 1",
                        "color": "#ffee13"
                    },
                    {
                        "name": "Orga Tag 2",
                        "color": "#12ee13"
                    },
                    {
                        "name": "Orga Tag 3",
                        "color": "#00ee13"
                    },
                ])
                DbUtils.insert_many_wrapper(curs, "gm_organization_tag_tagged_ids_t", [
                    {"organization_tag_id": tag_ids[0], "tagged_id": f"committee/{self.committee1_id}"},
                    {"organization_tag_id": tag_ids[0], "tagged_id": f"meeting/{self.meeting1_id}"},
                    {"organization_tag_id": tag_ids[1], "tagged_id": f"committee/{self.committee1_id}"},
                    {"organization_tag_id": tag_ids[2], "tagged_id": f"meeting/{self.meeting1_id}"},
                ])
            rows = DbUtils.select_id_wrapper(curs, "gm_organization_tag_tagged_ids_t", field_names=["id", "organization_tag_id", "tagged_id", "tagged_id_committee_id", "tagged_id_meeting_id"])
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
                    tag_id = DbUtils.insert_wrapper(curs, "organization_tag_t", {"name": "Orga Tag 1", "color": "#ffee13"})
                    DbUtils.insert_many_wrapper(curs, "gm_organization_tag_tagged_ids_t", [
                        {"organization_tag_id": tag_id, "tagged_id": f"committee/{self.committee1_id}"},
                        {"organization_tag_id": tag_id, "tagged_id": f"motion_state/{self.meeting1_id}"},
                    ])
        assert 'motion_state/1' in str(e)

    def test_generic_nGt_unique_constraint_error(self) -> None:
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                tag_id = DbUtils.insert_wrapper(curs, "organization_tag_t", {"name": "Orga Tag 1", "color": "#ffee13"})
                DbUtils.insert_wrapper(curs, "gm_organization_tag_tagged_ids_t", {"organization_tag_id": tag_id, "tagged_id": f"committee/{self.committee1_id}"})
            with pytest.raises(psycopg.DatabaseError) as e:
                with self.db_connection.transaction():
                    DbUtils.insert_wrapper(curs, "gm_organization_tag_tagged_ids_t", {"organization_tag_id": tag_id, "tagged_id": f"committee/{self.committee1_id}"})
            assert 'duplicate key value violates unique constraint' in str(e)

class EnumTests(BaseTestCase):
    def test_correct_singular_values_in_meeting(self) -> None:
        meeting_t = Table("meeting_t")
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                meeting = curs.execute(*meeting_t.select(meeting_t.language, meeting_t.export_pdf_fontsize, where=meeting_t.id==1)).fetchone()
                assert meeting["language"] == "en"
                assert meeting["export_pdf_fontsize"] == 10
                meeting = curs.execute(*meeting_t.update([meeting_t.language, meeting_t.export_pdf_fontsize], ["de", 11], where=meeting_t.id==1, returning=[meeting_t.id, meeting_t.language])).fetchone()
        assert meeting["language"] == "de"

    def test_wrong_language_in_meeting(self) -> None:
        meeting_t = Table("meeting_t")
        with self.db_connection.cursor() as curs:
            with pytest.raises(psycopg.DatabaseError) as e:
                with self.db_connection.transaction():
                    curs.execute(*meeting_t.update([meeting_t.language], ["xx"], where=meeting_t.id==1))
        assert 'violates check constraint "enum_meeting_language"' in str(e)

    def test_wrong_pdf_fontsize_in_meeting(self) -> None:
        meeting_t = Table("meeting_t")
        with self.db_connection.cursor() as curs:
            with pytest.raises(psycopg.DatabaseError) as e:
                with self.db_connection.transaction():
                    curs.execute(*meeting_t.update([meeting_t.export_pdf_fontsize], [22], where=meeting_t.id==1))
        assert 'violates check constraint "enum_meeting_export_pdf_fontsize"' in str(e)

    def test_correct_permissions_in_group(self) -> None:
        group_t = Table("group_t")
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                group = curs.execute(*group_t.select(group_t.permissions, where=group_t.id==1)).fetchone()
                assert "agenda_item.can_see_internal" in group["permissions"]
                assert "user.can_see" in group["permissions"]
                assert "chat.can_manage" not in group["permissions"]
                group["permissions"].remove("user.can_see")
                group["permissions"].append("chat.can_manage")
                sql = tuple(group_t.update([group_t.permissions], [DbUtils.get_pg_array_for_cu(group["permissions"]),], where=group_t.id==1, returning=[group_t.permissions]))
                group = curs.execute(*sql).fetchone()
        assert "agenda_item.can_see_internal" in group["permissions"]
        assert "user.can_see" not in group["permissions"]
        assert "chat.can_manage" in group["permissions"]

    def test_wrong_permissions_in_group(self) -> None:
        group_t = Table("group_t")
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                with pytest.raises(psycopg.DatabaseError) as e:
                    group = {"permissions": ["user.can_see", "invalid permission"]}
                    sql = tuple(group_t.update([group_t.permissions], [DbUtils.get_pg_array_for_cu(group["permissions"]),], where=group_t.id==1, returning=[group_t.permissions]))
                    group = curs.execute(*sql).fetchone()
        assert 'violates check constraint "enum_group_permissions"' in str(e)

class DataTypeTests(BaseTestCase):
    def test_color_type_correct(self) -> None:
        orga_tag_t = Table("organization_tag_t")
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                orga_tags = curs.execute(*orga_tag_t.insert(columns=[orga_tag_t.name, orga_tag_t.color], values=[['Foo', '#ff12cc'], ["Bar", "#1234AA"]], returning=[orga_tag_t.id, orga_tag_t.name, orga_tag_t.color])).fetchall()
                assert orga_tags[0] == {"id": 1, "name": "Foo", "color": "#ff12cc"}
                assert orga_tags[1] == {"id": 2, "name": "Bar", "color": "#1234AA"}

    def test_color_type_not_null_error(self) -> None:
        orga_tag_t = Table("organization_tag_t")
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                with pytest.raises(psycopg.DatabaseError) as e:
                    curs.execute(*orga_tag_t.insert(columns=[orga_tag_t.name, orga_tag_t.color], values=[['Foo', None]], returning=[orga_tag_t.id, orga_tag_t.name, orga_tag_t.color])).fetchone()
        assert 'null value in column "color" of relation "organization_tag_t" violates not-null constraint' in str(e)

    def test_color_type_null_correct(self) -> None:
        sl_t = Table("structure_level_t")
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                sl_id = curs.execute(*sl_t.insert(columns=[sl_t.name, sl_t.color, sl_t.meeting_id], values=[['Foo', None, 1]], returning=[sl_t.id])).fetchone()["id"]
                structure_level = curs.execute(*sl_t.select(sl_t.id, sl_t.color, where=sl_t.id==sl_id)).fetchone()
                assert structure_level == {"id": sl_id, "color": None}

    def test_color_type_empty_string_error(self) -> None:
        sl_t = Table("structure_level_t")
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                with pytest.raises(psycopg.DatabaseError) as e:
                    curs.execute(*sl_t.insert(columns=[sl_t.name, sl_t.color, sl_t.meeting_id], values=[['Foo', '', 1]], returning=[sl_t.id])).fetchone()["id"]
        assert """new row for relation "structure_level_t" violates check constraint "structure_level_t_color_check""" in str(e)

    def test_color_type_wrong_string_error(self) -> None:
        sl_t = Table("structure_level_t")
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                with pytest.raises(psycopg.DatabaseError) as e:
                    curs.execute(*sl_t.insert(columns=[sl_t.name, sl_t.color, sl_t.meeting_id], values=[['Foo', 'xxx', 1]], returning=[sl_t.id])).fetchone()["id"]
        assert """new row for relation "structure_level_t" violates check constraint "structure_level_t_color_check""" in str(e)

    def test_color_type_to_long_string_error(self) -> None:
        sl_t = Table("structure_level_t")
        with self.db_connection.cursor() as curs:
            with self.db_connection.transaction():
                with pytest.raises(psycopg.DatabaseError) as e:
                    curs.execute(*sl_t.insert(columns=[sl_t.name, sl_t.color, sl_t.meeting_id], values=[['Foo', '#1234567', 1]], returning=[sl_t.id])).fetchone()["id"]
        assert """value too long for type character varying(7)""" in str(e)
