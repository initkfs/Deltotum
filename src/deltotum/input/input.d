module deltotum.input.input;

class Input
{
    @property int lastKey;
    @property bool justPressed;

    bool pressed(int keyCode)
    {
        if (!justPressed)
        {
            return false;
        }

        return lastKey == keyCode;
    }
}
