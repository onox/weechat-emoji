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

with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;

with WeeChat;

with Emojis;

package body Plugin_Emoji is

   use WeeChat;

   package UTF renames Ada.Strings.UTF_Encoding;

   function Unicode (Number : Long_Integer) return UTF.UTF_8_String is
     (UTF.Wide_Wide_Strings.Encode ("" & Wide_Wide_Character'Val (Number)));

   function Unicode (Number_1, Number_2 : Long_Integer) return UTF.UTF_8_String is
     (UTF.Wide_Wide_Strings.Encode
        (Wide_Wide_Character'Val (Number_1) &
         Wide_Wide_Character'Val (Number_2)));

   procedure Replace_Text
     (Modified_Text : in out SU.Unbounded_String;
      Pair          : Emojis.Text_One_Point_Pair)
   is
      Text  : constant String := +Pair.Text;
      Emoji : constant UTF.UTF_8_String := Unicode (Pair.Point_1);
   begin
      loop
         declare
            Index : constant Natural := SU.Index (Modified_Text, Text);
         begin
            exit when Index = 0;
            SU.Replace_Slice (Modified_Text, Index, Index + Text'Length - 1, Emoji);
         end;
      end loop;
   end Replace_Text;

   function On_Print_Modifier
     (Plugin        : Plugin_Ptr;
      Modifier      : String;
      Modifier_Data : String;
      Text          : String) return String
   is
      Modified_Text : SU.Unbounded_String := +Text;
   begin
      for Pair of Emojis.Text_Emojis loop
         Replace_Text (Modified_Text, Pair);
      end loop;
      for Pair of Emojis.Lower_Case_Text_Emojis loop
         Replace_Text (Modified_Text, Pair);
      end loop;
      return +Modified_Text;
   end On_Print_Modifier;

   use type SU.Unbounded_String;

   procedure Replace_Slice
     (Text          : in out SU.Unbounded_String;
      Is_Completion : Boolean)
   is
      Text_List : constant String_List := Split (+Text, Separator => ":");
      Result    : SU.Unbounded_String;
   begin
      for Index in Text_List'Range loop
         if Index mod 2 = 0 then
            declare
               Found : Boolean := False;
               Slice : constant String := +Text_List (Index);
            begin
               if Index < Text_List'Last and not Is_Completion then
                  for Pair of Emojis.Name_Emojis_2 loop
                     if Pair.Text = Slice then
                        SU.Append (Result, Unicode (Pair.Point_1, Pair.Point_2) & " ");
                        Found := True;
                        exit;
                     end if;
                  end loop;

                  if not Found then
                     for Pair of Emojis.Name_Emojis_1 loop
                        if Pair.Text = Slice then
                           SU.Append (Result, Unicode (Pair.Point_1));
                           Found := True;
                           exit;
                        end if;
                     end loop;
                  end if;
               end if;

               if not Found then
                  if Index = Text_List'Last then
                     SU.Append (Result, ":" & Slice);
                  else
                     SU.Append (Result, ":" & Slice & ":");
                  end if;
               end if;
            end;
         else
            SU.Append (Result, Text_List (Index));
         end if;
      end loop;

      Text := Result;
   end Replace_Slice;

   function On_Input_Text_Content_Modifier
     (Plugin        : Plugin_Ptr;
      Modifier      : String;
      Modifier_Data : String;
      Text          : String) return String
   is
      Slices : String_List := Split (Text, Separator => " ");

      Is_Space : constant Boolean := Slices (Slices'Last) = "";
   begin
      for Index in Slices'Range loop
         declare
            Is_Completion : constant Boolean := Index = Slices'Last - 1 and Is_Space;
         begin
            Replace_Slice (Slices (Index), Index = Slices'Last or Is_Completion);

            for Pair of Emojis.Text_Emojis loop
               Replace_Text (Slices (Index), Pair);
            end loop;
            if Index < Slices'Last and not Is_Completion then
               for Pair of Emojis.Lower_Case_Text_Emojis loop
                  Replace_Text (Slices (Index), Pair);
               end loop;
            end if;
         end;
      end loop;

      return Join (Slices, " ");
   end On_Input_Text_Content_Modifier;

   function On_Emoji_Completion
     (Plugin     : Plugin_Ptr;
      Item       : String;
      Buffer     : Buffer_Ptr;
      Completion : Completion_Ptr) return Callback_Result is
   begin
      for Pair of Emojis.Name_Emojis_2 loop
         Add_Completion_Word (Plugin, Completion, ":" & (+Pair.Text) & ":");
      end loop;

      for Pair of Emojis.Name_Emojis_1 loop
         Add_Completion_Word (Plugin, Completion, ":" & (+Pair.Text) & ":");
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
