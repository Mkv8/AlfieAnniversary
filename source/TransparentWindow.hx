package;

@:cppFileCode('#include <windows.h>\n#include <dwmapi.h>\n\n#pragma comment(lib, "Dwmapi")')
class TransparentWindow
{
    @:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(2, 3, 5), 0, LWA_COLORKEY);
        }
    ')
    static public function enableTransparent(res:Int = 0)
    {
        return res;
    }

    @:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) & ~WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(2, 3, 5), 1, LWA_COLORKEY);
        }
    ')
    static public function disableTransparent(res:Int = 0)
    {
        return res;
    }
}