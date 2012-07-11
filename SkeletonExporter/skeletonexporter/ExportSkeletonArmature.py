# ##### BEGIN GPL LICENSE BLOCK #####
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# ##### END GPL LICENSE BLOCK #####

# <pep8 compliant>

bl_info = {
    "name": "Skeleton Exporter Armature",
    "author": "hi ku studios",
    "version": (0, 1),
    "blender": (2, 5, 7),
    "location": "File > Export > Skeletons (.skel)",
    "description": "Export Skeletons (.skel)",
    "warning": "",
    "support": 'OFFICIAL',
    "category": "Import-Export"}

import bpy
import math
import json

from bpy.props import StringProperty, IntProperty, BoolProperty
from bpy_extras.io_utils import ExportHelper

def write(filename):
  def getBoneInfo(bone):
    headx = bone.head.y
    heady = bone.head.z
    tailx = bone.tail.y
    taily = bone.tail.z
    angle = math.atan2(taily-heady, tailx-headx)
    children = {b.name: getBoneInfo(b) for b in bone.children}
    return {'head': {'x': headx, 'y': heady},
            'tail': {'x': tailx, 'y': taily},
            'angle': angle,
            'length': bone.length,
            'children': children}

  armature = bpy.data.armatures["Armature"]
  bones = {bone.name: getBoneInfo(bone) for bone in armature.bones if not bone.parent}

  fp = open(filename, "w")
  json.dump(bones, fp, separators=(',', ':'))
  fp.close()

class SkeletonExporter(bpy.types.Operator, ExportHelper):
    '''Save a python script which re-creates cameras and markers elsewhere'''
    bl_idname = "skeleton_animation.cameras"
    bl_label = "Export Skeleton Properties"
    filename_ext = ".skel"
    filter_glob = StringProperty(default="*.skel", options={'HIDDEN'})

    def execute(self, context):
        write("character.skel")
        return {'FINISHED'}

    def invoke(self, context, event):
        self.frame_start = context.scene.frame_start
        self.frame_end = context.scene.frame_end

        wm = context.window_manager
        wm.fileselect_add(self)
        return {'RUNNING_MODAL'}

def menu_export(self, context):
    import os
    default_path = os.path.splitext(bpy.data.filepath)[0] + ".skel"
    self.layout.operator(SkeletonExporter.bl_idname, text="Skeletons Armiture (.skel)").filepath = default_path


def register():
    bpy.utils.register_module(__name__)

    bpy.types.INFO_MT_file_export.append(menu_export)


def unregister():
    bpy.utils.unregister_module(__name__)

    bpy.types.INFO_MT_file_export.remove(menu_export)


if __name__ == "__main__":
    register()
