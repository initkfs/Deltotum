/**
 * Authors: initkfs
 */

int main(string[] args)
{
    import game.main_controller: MainController;
    const int result = (new MainController).run;
    return result;
}
