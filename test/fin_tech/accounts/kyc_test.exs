defmodule FinTech.Accounts.KYCTest do
  use FinTech.DataCase, async: true

  alias FinTech.Accounts

  describe "KYC submission" do
    test "successfully submits valid KYC data" do
      valid_attrs = %{
        "full_name" => "John Doe",
        "address" => "123 Elm St",
        "document_type" => "Passport",
        "document_number" => "A12345678"
      }

      assert {:ok, _kyc} = Accounts.submit_kyc(valid_attrs)
    end

    test "returns error for invalid KYC data" do
      invalid_attrs = %{
        "full_name" => "",
        "address" => "",
        "document_type" => "",
        "document_number" => ""
      }

      assert {:error, changeset} = Accounts.submit_kyc(invalid_attrs)
      assert changeset.valid? == false
      assert changeset.errors[:full_name] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:address] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:document_type] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:document_number] == {"can't be blank", [validation: :required]}
    end
  end
end
