#pragma once

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus


//These are opaque type handles
typedef struct Rive_File Rive_File;
typedef struct Rive_Factory Rive_Factory;
typedef struct Rive_Artboard_Instance Rive_ArtboardInstance;
typedef struct Rive_StateMachineInstance Rive_StateMachineInstance;
typedef struct Rive_RiveRenderer Rive_RiveRenderer;
typedef struct Rive_RiveRenderer{
  typedef struct FrameDescriptor {
    size_t renderTargetWidth;
    size_t renderTargetHeight;
  }
  FrameDescripter;


} Rive_RiveRenderer;

typedef enum {
  RIVE_IMPORT_SUCCESS = 0,
  RIVE_IMPORT_UNSUPPORTED_VERSION = 1,
  RIVE_IMPORT_MALFORMED = 2,
} RiveImportResult;


//rive::File
Rive_File* rive_file_import(const uint8_t* data, size_t size, Rive_Factory* factory, RiveImportResult* out_result);
void rive_file_release(Rive_File* file);
Rive_ArtboardInstance* rive_file_artboardDefault(Rive_File* file);

//rive::Artboard
size_t rive_artboard_stateMachineCount(Rive_ArtboardInstance* artboard);
Rive_StateMachineInstance* rive_artboard_defaultStateMachine(Rive_ArtboardInstance* artboard);
Rive_StateMachineInstance* rive_artboard_stateMachineAt(Rive_ArtboardInstance* artboard, size_t index);

//rive::stateMachineInstance
void rive_SMIadvanceAndApply(Rive_StateMachineInstance* sm, float secs);


//BindeableArtboard


#ifdef __cplusplus
}
#endif // __cplusplus
