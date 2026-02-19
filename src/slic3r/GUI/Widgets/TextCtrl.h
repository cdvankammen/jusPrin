#ifndef SLIC3R_GUI_WIDGETS_TEXTCTRL_H
#define SLIC3R_GUI_WIDGETS_TEXTCTRL_H

#ifdef __WXMSW__
class TextCtrl : public wxTextCtrl
{
public:
    using wxTextCtrl::wxTextCtrl;
    WXHBRUSH DoMSWControlColor(WXHDC pDC, wxColour colBg, WXHWND hWnd) { return wxTextCtrl::DoMSWControlColor(pDC, wxColour(), hWnd); }
};
#else
typedef wxTextCtrl TextCtrl;
#endif

#endif // SLIC3R_GUI_WIDGETS_TEXTCTRL_H
