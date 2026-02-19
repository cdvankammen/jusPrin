#include "PopupWindow.hpp"
#include <wx/display.h>

#if defined(__WXGTK__) && defined(SLIC3R_WAYLAND)
#include <gtk/gtk.h>
#endif

static wxWindow *GetTopParent(wxWindow *pWindow)
{
    wxWindow *pWin = pWindow;
    while (pWin->GetParent()) {
        pWin = pWin->GetParent();
        if (auto top = dynamic_cast<wxNonOwnedWindow*>(pWin))
            return top;
    }
    return pWin;
}

bool PopupWindow::Create(wxWindow *parent, int style)
{
    if (!wxPopupTransientWindow::Create(parent, style))
        return false;
    // On GTK (X11) we rely on activate events to detect top-level deactivate.
    // On Wayland transient parenting is important for correct stacking and
    // focus behavior; if configured at build time, set a transient parent
    // to the top-level window we derived from the provided parent.
#if defined(__WXGTK__)
    GetTopParent(parent)->Bind(wxEVT_ACTIVATE, &PopupWindow::topWindowActiavate, this);
#  ifdef SLIC3R_WAYLAND
    // Ensure the transient parent is a top-level non-owned window so Wayland
    // compositors can associate the popup with the main window.
    wxWindow* top = GetTopParent(parent);
    if (top) SetTransientParent(top);
#  endif
#endif
    return true;
}

PopupWindow::~PopupWindow()
{
#if defined(__WXGTK__)
    GetTopParent(this)->Unbind(wxEVT_ACTIVATE, &PopupWindow::topWindowActiavate, this);
#endif
}

#ifdef __WXGTK__
void PopupWindow::topWindowActiavate(wxActivateEvent &event)
{
    event.Skip();
    if (!event.GetActive() && IsShown()) DismissAndNotify();
}
#endif

// Clamp pos so the popup of the given size stays fully within the display work area.
wxPoint PopupWindow::PositionSafe(wxPoint pos, wxSize size)
{
    int displayIdx = wxDisplay::GetFromPoint(pos);
    if (displayIdx == wxNOT_FOUND)
        displayIdx = 0;
    wxDisplay display(static_cast<unsigned int>(displayIdx));
    wxRect workArea = display.GetClientArea();

    // Clamp horizontally
    if (pos.x + size.x > workArea.GetRight() + 1)
        pos.x = workArea.GetRight() + 1 - size.x;
    if (pos.x < workArea.GetLeft())
        pos.x = workArea.GetLeft();

    // Clamp vertically
    if (pos.y + size.y > workArea.GetBottom() + 1)
        pos.y = workArea.GetBottom() + 1 - size.y;
    if (pos.y < workArea.GetTop())
        pos.y = workArea.GetTop();

    return pos;
}

// Override Popup() so that on Wayland we set the transient parent before showing,
// which is required for correct popup positioning under Wayland compositors.
void PopupWindow::Popup(wxWindow *focus)
{
#if defined(__WXGTK__) && defined(SLIC3R_WAYLAND)
    wxWindow *top = GetTopParent(this);
    if (top && top->GetHandle() && GetHandle()) {
        gtk_window_set_transient_for(
            GTK_WINDOW(GetHandle()),
            GTK_WINDOW(top->GetHandle()));
    }
#endif
    wxPopupTransientWindow::Popup(focus);
}
