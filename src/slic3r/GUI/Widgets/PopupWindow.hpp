#ifndef slic3r_GUI_PopupWindow_hpp_
#define slic3r_GUI_PopupWindow_hpp_

#include <wx/popupwin.h>
#include <wx/display.h>

class PopupWindow : public wxPopupTransientWindow
{
public:
    PopupWindow() {}

    ~PopupWindow();

    PopupWindow(wxWindow *parent, int style = wxBORDER_NONE)
        { Create(parent, style); }
    
    bool Create(wxWindow *parent, int flags = wxBORDER_NONE);
    // Clamp `pos` so that a popup of `size` stays within the display work area.
    // Returns the adjusted (safe) screen position.
    wxPoint PositionSafe(wxPoint pos, wxSize size);

    // Override Popup() to set the transient parent on Wayland before showing.
    virtual void Popup(wxWindow *focus = nullptr) override;

private:
#ifdef __WXGTK__
    void topWindowActiavate(wxActivateEvent &event);
#endif
};

#endif // !slic3r_GUI_PopupWindow_hpp_
