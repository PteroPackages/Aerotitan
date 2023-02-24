require "./spec_helper"

describe Aero::Template do
  data = JSON.parse <<-JSON
    {
      "2fa": false,
      "created_at": "2022-02-19T16:43:03+00:00",
      "email": "user@example.com",
      "external_id": null,
      "first_name": "example",
      "id": 5,
      "language": "en",
      "last_name": "user",
      "root_admin": true,
      "updated_at": "2022-09-15T17:32:40+00:00",
      "username": "exampleuser",
      "uuid": "c020fc84-15bb-4d60-b639-6a2ab27b2dca"
    }
    JSON

  describe "compile" do
    it "tests equality comparison" do
      result = Aero::Template.compile(
        "user.external_id == null",
        "user",
        Aero::Models::USER_FIELDS,
      )

      result.execute(data).should be_true
    end

    it "tests inequality comparison" do
      result = Aero::Template.compile(
        %(user.first_name != "user"),
        "user",
        Aero::Models::USER_FIELDS,
      )

      result.execute(data).should be_true
    end

    it "tests greater than comparison" do
      result = Aero::Template.compile(
        "user.id > 2",
        "user",
        Aero::Models::USER_FIELDS,
      )

      result.execute(data).should be_true
    end

    it "tests less than comparison" do
      result = Aero::Template.compile(
        "user.id < 5",
        "user",
        Aero::Models::USER_FIELDS,
      )

      result.execute(data).should be_false
    end

    it "fails for invalid syntax" do
      expect_raises Aero::SyntaxError do
        Aero::Template.compile(
          "user.id & 10",
          "user",
          Aero::Models::USER_FIELDS,
        )
      end
    end

    it "fails for invalid comparison" do
      expect_raises Aero::ComparisonError do
        Aero::Template.compile(
          "user.first_name > 10",
          "user",
          Aero::Models::USER_FIELDS,
        )
      end
    end
  end
end
