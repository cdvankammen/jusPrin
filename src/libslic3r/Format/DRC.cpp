#include "DRC.hpp"
#include "libslic3r/TriangleMesh.hpp"
#include "libslic3r/Model.hpp"

namespace Slic3r {

// Stub implementations - Draco library not available in this build
bool load_drc(const char *path, TriangleMesh *meshptr)
{
    // FIXME: Draco library not built - DRC format not supported
    return false;
}

bool load_drc(const char *path, Model *model, const char *object_name)
{
    // FIXME: Draco library not built - DRC format not supported
    return false;
}

bool store_drc(const char* path, TriangleMesh* mesh, int bits, int speed)
{
    // FIXME: Draco library not built - DRC format not supported
    return false;
}

bool store_drc(const char* path, ModelObject* model_object, int bits, int speed)
{
    // FIXME: Draco library not built - DRC format not supported
    return false;
}

bool store_drc(const char* path, Model* model, int bits, int speed)
{
    // FIXME: Draco library not built - DRC format not supported
    return false;
}

}; // namespace Slic3r
