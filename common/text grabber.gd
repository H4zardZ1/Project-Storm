extends Node



const TEXT_CONTENT_PATH = "res://textcontent/"

# 
# static func update_translation() -> void:
#     var directory_head := DirAccess.open(TEXT_CONTENT_PATH)
#     var invalid_directories: Array[String] = []
#     var duplicate_names: Array[String] = []
    # Here, file position will be used. Translators will need to be careful about where the file is placed.
    # The first folder name determines the language(only language, no locale)
    # The rest(directory and file name) will be used for the translation key.
#     for language_dir in directory_head.get_directories():
#         directory_head.change_dir(language_dir)
#         var path_stack: Array[String] = []
#         var translation_resource := Translation.new()
#         translation_resource.locale = language_dir.left(2)
#         path_stack.append(directory_head.get_directories())
#         path_stack.append(directory_head.get_files())
#         while not path_stack.is_empty():
            
#         TranslationServer.add_translation(translation_resource)
#     if not invalid_directories.is_empty():
#         push_warning("Invalid directories at {0}".format([invalid_directories.reduce(_list_array)]))
#     if not duplicate_names.is_empty():
#         push_warning("The following have different names: {0}".format([invalid_directories.reduce(_list_array)]))


# static func _list_array(accum, t):
#     if accum:
#         return accum + ", '{0}'".format([t])
#     else:
#         return "'{0}'".format([t])