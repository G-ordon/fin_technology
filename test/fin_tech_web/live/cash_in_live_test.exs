defmodule FinTechWeb.CashInLiveTest do
  use FinTechWeb.ConnCase

  import Phoenix.LiveViewTest
  import FinTech.TransactionsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_cash_in(_) do
    cash_in = cash_in_fixture()
    %{cash_in: cash_in}
  end

  describe "Index" do
    setup [:create_cash_in]

    test "lists all cash_ins", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/cash_ins")

      assert html =~ "Listing Cash ins"
    end

    test "saves new cash_in", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cash_ins")

      assert index_live |> element("a", "New Cash in") |> render_click() =~
               "New Cash in"

      assert_patch(index_live, ~p"/cash_ins/new")

      assert index_live
             |> form("#cash_in-form", cash_in: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cash_in-form", cash_in: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cash_ins")

      html = render(index_live)
      assert html =~ "Cash in created successfully"
    end

    test "updates cash_in in listing", %{conn: conn, cash_in: cash_in} do
      {:ok, index_live, _html} = live(conn, ~p"/cash_ins")

      assert index_live |> element("#cash_ins-#{cash_in.id} a", "Edit") |> render_click() =~
               "Edit Cash in"

      assert_patch(index_live, ~p"/cash_ins/#{cash_in}/edit")

      assert index_live
             |> form("#cash_in-form", cash_in: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cash_in-form", cash_in: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cash_ins")

      html = render(index_live)
      assert html =~ "Cash in updated successfully"
    end

    test "deletes cash_in in listing", %{conn: conn, cash_in: cash_in} do
      {:ok, index_live, _html} = live(conn, ~p"/cash_ins")

      assert index_live |> element("#cash_ins-#{cash_in.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#cash_ins-#{cash_in.id}")
    end
  end

  describe "Show" do
    setup [:create_cash_in]

    test "displays cash_in", %{conn: conn, cash_in: cash_in} do
      {:ok, _show_live, html} = live(conn, ~p"/cash_ins/#{cash_in}")

      assert html =~ "Show Cash in"
    end

    test "updates cash_in within modal", %{conn: conn, cash_in: cash_in} do
      {:ok, show_live, _html} = live(conn, ~p"/cash_ins/#{cash_in}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Cash in"

      assert_patch(show_live, ~p"/cash_ins/#{cash_in}/show/edit")

      assert show_live
             |> form("#cash_in-form", cash_in: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#cash_in-form", cash_in: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/cash_ins/#{cash_in}")

      html = render(show_live)
      assert html =~ "Cash in updated successfully"
    end
  end
end
