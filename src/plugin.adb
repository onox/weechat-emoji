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

with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;

with WeeChat;

with Emojis;

package body Plugin is

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
     (Data          : Void_Ptr;
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
     (Data          : Void_Ptr;
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
     (Data       : Void_Ptr;
      Item       : String;
      Buffer     : Buffer_Ptr;
      Completion : Completion_Ptr) return Callback_Result is
   begin
      for Pair of Emojis.Name_Emojis_2 loop
         Add_Completion_Word (Completion, ":" & (+Pair.Text) & ":");
      end loop;

      for Pair of Emojis.Name_Emojis_1 loop
         Add_Completion_Word (Completion, ":" & (+Pair.Text) & ":");
      end loop;

      return OK;
   end On_Emoji_Completion;

   procedure Plugin_Initialize is
      Option : constant Config_Option := Get_Config_Option ("weechat.completion.default_template");
   begin
      On_Modifier ("weechat_print", On_Print_Modifier'Access);
      On_Modifier ("input_text_content", On_Input_Text_Content_Modifier'Access);

      On_Completion ("emoji_names", "Complete :emoji:", On_Emoji_Completion'Access);

      if SF.Index (Option.Value, "emoji_names") = 0 then
         declare
            Result : constant Option_Set := Option.Set (Option.Value & "|%(emoji_names)");
         begin
            pragma Assert (Result /= Error);
         end;
      end if;
   end Plugin_Initialize;

   procedure Plugin_Finalize is null;

begin
   WeeChat.Register
     ("emoji", "onox", "Displays emoji with Ada 2012", "1.0", "Apache-2.0",
      Plugin_Initialize'Access, Plugin_Finalize'Access);
end Plugin;
