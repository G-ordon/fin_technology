defmodule FinTechWeb.ErrorHelpers do
  def translate_error({msg, _opts}) do
    # Customize how error messages are formatted here.
    # Example: Using Gettext for translations if you have that set up.
    # Gettext.dgettext("errors", msg, opts)
    msg
  end

  def translate_error(msg), do: msg
end
