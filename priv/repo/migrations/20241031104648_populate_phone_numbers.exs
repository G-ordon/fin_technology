defmodule FinTech.Repo.Migrations.PopulatePhoneNumbers do
  use Ecto.Migration

  def up do
    # Update users with a unique temporary phone number
    execute("""
      UPDATE users
      SET phone_number = CONCAT('temp_', id)
      WHERE phone_number IS NULL
    """)
  end

  def down do
    execute("UPDATE users SET phone_number = NULL WHERE phone_number LIKE 'temp_%'")
  end
end
