import os
from datetime import datetime
from typing import Any
from unittest import TestCase

import psycopg
import pytest

# ADMIN_USERNAME = "admin"
# ADMIN_PASSWORD = "admin"
#db_connection: psycopg.Connection = None

class BaseTestCase(TestCase):
    db_connection: psycopg.Connection = None
    curs: psycopg.Cursor = None

    @classmethod
    def setup_class(cls):
        """setup any state specific to the execution of the given class (which
        usually contains tests).
        """
        start = datetime.now()
        env = os.environ
        try:
            cls.db_connection = psycopg.connect(f"dbname='{env['POSTGRES_DB']}' user='{env['POSTGRES_USER']}' host='{env['POSTGRES_HOST']}' password='{env['PGPASSWORD']}'")
        except Exception as e:
            raise Exception(f"Cannot connect to database: {e.message}") 
        cls.db_connection.autocommit = False
        print(f"class setup: {datetime.now() - start}")


    @classmethod
    def teardown_class(cls):
        """teardown any state that was previously setup with a call to
        setup_class.
        """
        start = datetime.now()
        cls.db_connection.close()
        print(f"class teardown: {datetime.now() - start}")

    def setUp(self) -> None:
        start = datetime.now()
        #global db_connection
        super().setUp()
        env = os.environ
        self.curs = self.db_connection.cursor()
        self.curs.execute(f"select truncate_tables('{env['POSTGRES_USER']}');")
        self.db_connection.commit()
        print(f"test setup: {datetime.now() - start}")

    def tearDown(self) -> None:
        start = datetime.now()
        super().tearDown()
        self.curs.close()
        print(f"test teardown: {datetime.now() - start}")

        # self.created_fqids = set()
        # self.create_model(
        #     "user/1",
        #     {
        #         "username": ADMIN_USERNAME,
        #         "password": self.auth.hash(ADMIN_PASSWORD),
        #         "default_password": ADMIN_PASSWORD,
        #         "is_active": True,
        #         "organization_management_level": "superadmin",
        #         "organization_id": ONE_ORGANIZATION_ID,
        #     },
        # )
        # self.create_model(
        #     ONE_ORGANIZATION_FQID,
        #     {
        #         "name": "OpenSlides Organization",
        #         "default_language": "en",
        #         "user_ids": [1],
        #     },
        # )
        # self.client = self.create_client(self.update_vote_service_auth_data)
        # if self.auth_data:
        #     # Reuse old login data to avoid a new login request
        #     self.client.update_auth_data(self.auth_data)
        # else:
        #     # Login and save copy of auth data for all following tests
        #     self.client.login(ADMIN_USERNAME, ADMIN_PASSWORD)
        #     BaseSystemTestCase.auth_data = deepcopy(self.client.auth_data)
        # self.anon_client = self.create_client()


    #@pytest.fixture(scope="session", autouse=True)
    def setup_db_connect(self):
        start = datetime.now()
        global db_connection
        env = os.environ
        try:
            db_connection = psycopg.connect(f"dbname='{env['POSTGRES_DB']}' user='{env['POSTGRES_USER']}' host='{env['POSTGRES_HOST']}' password='{env['PGPASSWORD']}'")
        except Exception as e:
            raise Exception(f"Cannot connect to database: {e.message}") 
        db_connection.autocommit = False
        print(f"session setup: {datetime.now() - start}")
        yield db_connection
        start = datetime.now()
        db_connection.close()
        print(f"session teardown: {datetime.now() - start}")

    # def load_example_data(self) -> None:
    #     """
    #     Useful for debug purposes when an action fails with the example data.
    #     Do NOT use in final tests since it takes a long time.
    #     """
    #     example_data = get_initial_data_file(EXAMPLE_DATA_FILE)
    #     self._load_data(example_data)

    # def load_json_data(self, filename: str) -> None:
    #     """
    #     Useful for debug purposes when an action fails with a specific dump.
    #     Do NOT use in final tests since it takes a long time.
    #     """
    #     with open(filename) as file:
    #         data = json.loads(file.read())
    #     self._load_data(data)

    # def _load_data(self, raw_data: dict[str, dict[str, Any]]) -> None:
    #     data = {}
    #     for collection, models in raw_data.items():
    #         if collection == "_migration_index":
    #             continue
    #         for model_id, model in models.items():
    #             data[f"{collection}/{model_id}"] = {
    #                 f: v for f, v in model.items() if not f.startswith("meta_")
    #             }
    #     self.set_models(data)

    # def create_client(
    #     self, on_auth_data_changed: Callable[[AuthData], None] | None = None
    # ) -> Client:
    #     return Client(self.app, on_auth_data_changed)

    # def login(self, user_id: int) -> None:
    #     """
    #     Login the given user by fetching the default password from the datastore.
    #     """
    #     user = self.get_model(f"user/{user_id}")
    #     assert user.get("default_password")
    #     self.client.login(user["username"], user["default_password"])

    # def update_vote_service_auth_data(self, auth_data: AuthData) -> None:
    #     self.vote_service.set_authentication(
    #         auth_data["access_token"], auth_data["refresh_id"]
    #     )

    # def get_application(self) -> WSGIApplication:
    #     raise NotImplementedError()

    # def assert_status_code(self, response: Response, code: int) -> None:
    #     if (
    #         response.status_code != code
    #         and response.json
    #         and response.json.get("message")
    #     ):
    #         print(response.json)
    #     self.assertEqual(response.status_code, code)

    # def create_model(
    #     self, fqid: str, data: dict[str, Any] = {}, deleted: bool = False
    # ) -> None:
    #     write_request = self.get_write_request(
    #         self.get_create_events(fqid, data, deleted)
    #     )
    #     self.datastore.write(write_request)

    # def update_model(self, fqid: str, data: dict[str, Any]) -> None:
    #     write_request = self.get_write_request(self.get_update_events(fqid, data))
    #     self.datastore.write(write_request)

    # def get_create_events(
    #     self, fqid: str, data: dict[str, Any] = {}, deleted: bool = False
    # ) -> list[Event]:
    #     self.created_fqids.add(fqid)
    #     data["id"] = id_from_fqid(fqid)
    #     self.validate_fields(fqid, data)
    #     events = [Event(type=EventType.Create, fqid=fqid, fields=data)]
    #     if deleted:
    #         events.append(Event(type=EventType.Delete, fqid=fqid))
    #     return events

    # def get_update_events(self, fqid: str, data: dict[str, Any]) -> list[Event]:
    #     self.validate_fields(fqid, data)
    #     return [Event(type=EventType.Update, fqid=fqid, fields=data)]

    # def get_write_request(self, events: list[Event]) -> WriteRequest:
    #     return WriteRequest(events, user_id=0)

    # def set_models(self, models: dict[str, dict[str, Any]]) -> None:
    #     """
    #     Can be used to set multiple models at once, independent of create or update.
    #     Uses self.created_fqids to determine which models are already created. If you want to update
    #     a model which was not set in the test but created via an action, you may have to add the
    #     fqid to this set.
    #     """
    #     events: list[Event] = []
    #     for fqid, model in models.items():
    #         if fqid in self.created_fqids:
    #             events.extend(self.get_update_events(fqid, model))
    #         else:
    #             events.extend(self.get_create_events(fqid, model))
    #     write_request = self.get_write_request(events)
    #     self.datastore.write(write_request)

    # def validate_fields(self, fqid: str, fields: dict[str, Any]) -> None:
    #     model = model_registry[collection_from_fqid(fqid)]()
    #     for field_name, value in fields.items():
    #         try:
    #             model.get_field(field_name).validate_with_schema(
    #                 fqid, field_name, value
    #             )
    #         except ActionException as e:
    #             raise JsonSchemaException(e.message)

    # @with_database_context
    # def get_model(self, fqid: str) -> dict[str, Any]:
    #     model = self.datastore.get(
    #         fqid,
    #         mapped_fields=[],
    #         get_deleted_models=DeletedModelsBehaviour.ALL_MODELS,
    #         lock_result=False,
    #         use_changed_models=False,
    #     )
    #     self.assertTrue(model)
    #     self.assertEqual(model.get("id"), id_from_fqid(fqid))
    #     return model

    # def assert_model_exists(
    #     self, fqid: str, fields: dict[str, Any] | None = None
    # ) -> dict[str, Any]:
    #     return self._assert_fields(fqid, (fields or {}) | {"meta_deleted": False})

    # def assert_model_not_exists(self, fqid: str) -> None:
    #     with self.assertRaises(DatastoreException):
    #         self.get_model(fqid)

    # def assert_model_deleted(
    #     self, fqid: str, fields: dict[str, Any] | None = None
    # ) -> dict[str, Any]:
    #     return self._assert_fields(fqid, (fields or {}) | {"meta_deleted": True})

    # def _assert_fields(
    #     self, fqid: FullQualifiedId, fields: dict[str, Any]
    # ) -> dict[str, Any]:
    #     model = self.get_model(fqid)
    #     model_cls = model_registry[collection_from_fqid(fqid)]()
    #     for field_name, value in fields.items():
    #         if not is_reserved_field(field_name) and value is not None:
    #             # assert that the field actually exists to detect errors in the tests
    #             model_cls.get_field(field_name)
    #         self.assertEqual(
    #             model.get(field_name),
    #             value,
    #             f"Models differ in field {field_name}!",
    #         )
    #     return model

    # def assert_defaults(self, model: type[Model], instance: dict[str, Any]) -> None:
    #     for field in model().get_fields():
    #         if getattr(field, "default", None) is not None:
    #             self.assertEqual(
    #                 field.default,
    #                 instance.get(field.own_field_name),
    #                 f"Field {field.own_field_name}: Value {instance.get(field.own_field_name, 'None')} is not equal default value {field.default}.",
    #             )

    # @with_database_context
    # def assert_model_count(self, collection: str, meeting_id: int, count: int) -> None:
    #     db_count = self.datastore.count(
    #         collection,
    #         FilterOperator("meeting_id", "=", meeting_id),
    #         lock_result=False,
    #     )
    #     self.assertEqual(db_count, count)
