module api.dm.back.sdl3.sdl_dialog;

import api.dm.com.com_result : ComResult;
import api.dm.com.platforms.com_dialog : ComDialog;
import api.dm.com.graphics.com_window : ComWindow;
import api.dm.back.sdl3.base.sdl_object : SdlObject;

import api.dm.com.platforms.com_dialog : ComDialog, ComDialogFilter;
import std.string : toStringz, fromStringz;
import api.core.utils.queues.ring_buffer_spsc : RingBuffer;
import core.thread.osthread : thread_attachThis;
import core.thread.threadbase : thread_detachThis;
import core.thread : Thread;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 * SDL note: On Linux, dialogs may require XDG Portals, which requires DBus, which requires an event-handling loop.
 */
class SDLDialog : SdlObject, ComDialog
{
    struct DelegateContext
    {
        ulong ownerThread;
        SDLDialog ownerDialog;
        void delegate(string[]) onAction;
        ComDialogFilter[] filters;
        void* nativeFilters;
        string[] paths;
        ptrdiff_t filterIndex = -1;
    }

    __gshared RingBuffer!(DelegateContext*, 10) __dgQueue;

    void initialize()
    {
        __dgQueue.initialize;
    }

    /** 
     * https://wiki.libsdl.org/SDL3/SDL_DialogFileCallback
     * NULL, an error occurred. Details can be obtained with SDL_GetError().
     * A pointer to NULL, the user either didn't choose any file or canceled the dialog.
     * A pointer to non-NULL, the user chose one or more files. The argument is a null-terminated array of pointers to UTF-8 encoded strings, each containing a path.
     * The filter argument is the index of the filter that was selected, or -1 if no filter was selected or if the platform or method doesn't support fetching the selected filter.
     * In Android, the filelist are content:// URIs. They should be opened using SDL_IOFromFile() with appropriate modes. This applies both to open and save file dialog.
     */
    extern (C) static dialogCallback(void* userdata, const(char*)* filelist, int filterIndex) nothrow
    {

        if (!filelist)
        {
            import core.stdc.stdio : fprintf, stderr;

            fprintf(stderr, "ERROR in native dialog callback: %s\n", SDL_GetError());
            return;
        }

        auto dialogCtx = cast(DelegateContext*) userdata;
        if (!dialogCtx)
        {
            import core.stdc.stdio : stderr, fputs;

            fputs("ERROR. Dialog context is empty for native callback\n", stderr);
            return;
        }

        try
        {

            bool isNonOwnerThread = Thread.getThis.id != dialogCtx.ownerThread;
            if (isNonOwnerThread)
            {
                thread_attachThis;
                //dialogCtx.ownerDialog.logger.trace("Attach native dialog thread");
            }

            scope (exit)
            {
                if (isNonOwnerThread)
                {
                    //dialogCtx.ownerDialog.logger.trace("Detach native dialog thread");
                    thread_detachThis;
                }
            }

            string[] paths;
            if (*filelist)
            {
                // SDL_Log("The user did not select any file. Most likely, the dialog was canceled.");
                while (*filelist)
                {
                    paths ~= (*filelist).fromStringz.idup;
                    filelist++;
                }
            }

            dialogCtx.paths = paths;
            dialogCtx.filterIndex = filterIndex;
            DelegateContext*[1] ctx = [dialogCtx];

            if (!dialogCtx.ownerDialog.__dgQueue.write(ctx))
            {
                import std.stdio : stderr, writefln;

                stderr.writeln("Write to dialog context queue failed, size: %d", __dgQueue.size);
            }
        }
        catch (Exception e)
        {
            import std.string : toStringz;

            import core.stdc.stdio : fprintf, stderr;

            fprintf(stderr, "Exception from native dialog callback: %s\n", e.message.toStringz);

            //dialogCtx.ownerDialog.logger.error("Exception in native dialog callback: %s", SDL_GetError()
            //       .fromStringz.idup);
        }
    }

    protected long threadId() nothrow
    {
        try
        {
            return Thread.getThis.id;
        }
        catch (Exception e)
        {
            import std.string : toStringz;
            import core.stdc.stdio : fprintf, stderr;

            fprintf(stderr, "Exception from thread id getter: %s\n", e.message.toStringz);
            return -1;
        }
    }

    void openFile(ComWindow window, void delegate(string[]) onAction, string defaultLocation = null, bool isAllowMany = true, ComDialogFilter[] filters = null)
    {
        SDL_DialogFileFilter[] sdlFilters;
        if (filters.length == 0)
        {
            auto defaultFilter = ComDialogFilter();
            sdlFilters ~= SDL_DialogFileFilter(defaultFilter.name.toStringz, defaultFilter
                    .pattern.toStringz);
        }
        else
        {
            import std.string : toStringz;

            sdlFilters.reserve(filters.length);
            foreach (filter; filters)
            {
                sdlFilters ~= SDL_DialogFileFilter(filter.name.toStringz, filter.pattern.toStringz);
            }
        }

        import Mem = api.core.utils.mem;

        void* userData = cast(void*) new DelegateContext(threadId, this, onAction, filters, sdlFilters
                .ptr);
        Mem.addRootSafe(userData);

        auto windowPtr = window.nativePtr.castSafe!(SDL_Window*);
        SDL_ShowOpenFileDialog(&dialogCallback, userData, windowPtr, sdlFilters.ptr, cast(
                int) sdlFilters.length, defaultLocation.toStringz, isAllowMany);
    }

    void openDir(ComWindow window, void delegate(string[]) onAction, string defaultLocation = null, bool isAllowMany = true)
    {
        import Mem = api.core.utils.mem;

        void* userData = cast(void*) new DelegateContext(threadId, this, onAction);
        Mem.addRootSafe(userData);

        auto windowPtr = window.nativePtr.castSafe!(SDL_Window*);
        SDL_ShowOpenFolderDialog(&dialogCallback, userData, windowPtr, defaultLocation.toStringz, isAllowMany);
    }

    void saveFile(ComWindow window, void delegate(string[]) onAction, string defaultLocation = "/", ComDialogFilter[] filters = null)
    {
        SDL_DialogFileFilter[] sdlFilters;
        if (filters.length == 0)
        {
            auto defaultFilter = ComDialogFilter();
            sdlFilters ~= SDL_DialogFileFilter(defaultFilter.name.toStringz, defaultFilter
                    .pattern.toStringz);
        }
        else
        {
            import std.string : toStringz;

            sdlFilters.reserve(filters.length);
            foreach (filter; filters)
            {
                sdlFilters ~= SDL_DialogFileFilter(filter.name.toStringz, filter.pattern.toStringz);
            }
        }

        import Mem = api.core.utils.mem;

        void* userData = cast(void*) new DelegateContext(threadId, this, onAction, filters, sdlFilters
                .ptr);
        Mem.addRootSafe(userData);

        auto windowPtr = window.nativePtr.castSafe!(SDL_Window*);
        SDL_ShowSaveFileDialog(&dialogCallback, userData, windowPtr, sdlFilters.ptr, cast(
                int) sdlFilters.length, defaultLocation.toStringz);
    }

    void processCallback()
    {
        if (!__dgQueue.isEmpty)
        {
            DelegateContext*[1] ctxRead;
            if (!__dgQueue.read(ctxRead))
            {
                import core.stdc.stdio : stderr, fputs;

                fputs("ERROR. Unable to read context from native dialog queue\n", stderr);
            }

            DelegateContext* ctx = ctxRead[0];
            if (ctx.onAction)
            {
                ctx.onAction(ctx.paths);
            }
        }
    }

}
