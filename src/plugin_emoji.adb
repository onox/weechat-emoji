--  SPDX-License-Identifier: Apache-2.0
--
--  Copyright (c) 2020 onox <denkpadje@gmail.com>
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.

with System;

with Interfaces.C;

with WeeChat;

with Emojis;

package body Plugin_Emoji is

   use WeeChat;
   use type SU.Unbounded_String;

   function On_Print_Modifier
     (Plugin        : Plugin_Ptr;
      Modifier      : String;
      Modifier_Data : String;
      Text          : String) return String is
   begin
      return Emojis.Replace (Text);
   end On_Print_Modifier;

   function On_Input_Text_Content_Modifier
     (Plugin        : Plugin_Ptr;
      Modifier      : String;
      Modifier_Data : String;
      Text          : String) return String is
   begin
      return Emojis.Replace (Text, Completions => Emojis.Lower_Case_Text_Emojis);
   end On_Input_Text_Content_Modifier;

   function On_Emoji_Completion
     (Plugin     : Plugin_Ptr;
      Item       : String;
      Buffer     : Buffer_Ptr;
      Completion : Completion_Ptr) return Callback_Result is
   begin
      for Label of Emojis.Labels loop
         Add_Completion_Word (Plugin, Completion, ":" & (+Label) & ":");
      end loop;

      return OK;
   end On_Emoji_Completion;

   procedure Plugin_Initialize (Plugin : Plugin_Ptr) is
      Option : constant Config_Option :=
        Get_Config_Option (Plugin, "weechat.completion.default_template");
   begin
      On_Modifier (Plugin, "weechat_print", On_Print_Modifier'Access);
      On_Modifier (Plugin, "input_text_content", On_Input_Text_Content_Modifier'Access);

      On_Completion (Plugin, "emoji_names", "Complete :emoji:", On_Emoji_Completion'Access);

      if SF.Index (WeeChat.Value (Option), "emoji_names") = 0 then
         declare
            Result : constant Option_Set :=
              Set (Option, WeeChat.Value (Option) & "|%(emoji_names)");
         begin
            pragma Assert (Result /= Error);
         end;
      end if;
   end Plugin_Initialize;

   procedure Plugin_Finalize (Plugin : Plugin_Ptr) is null;

   Plugin_Name : constant C_String := "emoji" & L1.NUL
     with Export, Convention => C, External_Name => "weechat_plugin_name";

   Plugin_Author : constant C_String := "onox" & L1.NUL
     with Export, Convention => C, External_Name => "weechat_plugin_author";

   Plugin_Description : constant C_String := "Displays emojis with Ada 2012" & L1.NUL
     with Export, Convention => C, External_Name => "weechat_plugin_description";

   Plugin_Version : constant C_String := "1.0" & L1.NUL
     with Export, Convention  => C, External_Name => "weechat_plugin_version";

   Plugin_License : constant C_String := "Apache-2.0" & L1.NUL
     with Export, Convention => C, External_Name => "weechat_plugin_license";

   Plugin_API_Version : constant String := WeeChat.Plugin_API_Version
     with Export, Convention => C, External_Name => "weechat_plugin_api_version";

   function Plugin_Init
     (Object : Plugin_Ptr;
      Argc   : Interfaces.C.int;
      Argv   : System.Address) return Callback_Result
   with Export, Convention => C, External_Name => "weechat_plugin_init";

   function Plugin_End (Object : Plugin_Ptr) return Callback_Result
     with Export, Convention => C, External_Name => "weechat_plugin_end";

   function Plugin_Init
     (Object : Plugin_Ptr;
      Argc   : Interfaces.C.int;
      Argv   : System.Address) return Callback_Result is
   begin
      return Plugin_Init (Object, Plugin_Initialize'Access);
   end Plugin_Init;

   function Plugin_End (Object : Plugin_Ptr) return Callback_Result is
   begin
      return Plugin_End (Object, Plugin_Finalize'Access);
   end Plugin_End;

end Plugin_Emoji;
