#!/usr/bin/python
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
    "name": "Skeleton Exporter Animation",
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
  sce = bpy.context.scene
  armature = bpy.data.objects["Armature"]
  framecount = 0
  start_frame, end_frame = armature.animation_data.action.frame_range
  frames = []
  for frame in range(int(start_frame), int(end_frame) + 1):
    sce.frame_set(frame)

    #calculate and write the time of the frame
    time = framecount/sce.render.fps
    framecount = framecount + 1

    #print out the bones' positions, angles, and lengths
    bones = []
    for pose_bone in armature.pose.bones:
      #calculate bone angle and length
      headx = pose_bone.head.y
      heady = pose_bone.head.z
      tailx = pose_bone.tail.y
      taily = pose_bone.tail.z
      angle = math.atan2(taily-heady, tailx-headx)
      bone = {}
      bone["head"]   = {'x': headx, 'y': heady}
      bone["tail"]   = {'x': tailx, 'y': taily}
      bone["angle"]  = angle
      bone["length"] = pose_bone.length
      bones.append(bone)

    frame = {'time': time, 'bones': bones, 'framecount': framecount} #TODO: maybe include the framecount
    frames.append(frame)
  fp = open(filename, "w")
  json.dump(frames, fp, separators=(',', ':'))
  fp.close()

class SkeletonExporter(bpy.types.Operator, ExportHelper):
    '''Save a python script which re-creates cameras and markers elsewhere'''
    bl_idname = "skeleton_animation.cameras"
    bl_label = "Export Skeleton Animation Properties"
    filename_ext = ".skel"
    filter_glob = StringProperty(default="*.skel", options={'HIDDEN'})

    def execute(self, context):
        write("characteranimation.skel")
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
    self.layout.operator(SkeletonExporter.bl_idname, text="Skeleton Animation (.skel)").filepath = default_path


def register():
    bpy.utils.register_module(__name__)

    bpy.types.INFO_MT_file_export.append(menu_export)


def unregister():
    bpy.utils.unregister_module(__name__)

    bpy.types.INFO_MT_file_export.remove(menu_export)


if __name__ == "__main__":
    register()

