------------------------------------------------------------------------------
--                              Ada Web Server                              --
--                                                                          --
--                            Copyright (C) 2000                            --
--                      Dmitriy Anisimkov & Pascal Obry                     --
--                                                                          --
--  This library is free software; you can redistribute it and/or modify    --
--  it under the terms of the GNU General Public License as published by    --
--  the Free Software Foundation; either version 2 of the License, or (at   --
--  your option) any later version.                                         --
--                                                                          --
--  This library is distributed in the hope that it will be useful, but     --
--  WITHOUT ANY WARRANTY; without even the implied warranty of              --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       --
--  General Public License for more details.                                --
--                                                                          --
--  You should have received a copy of the GNU General Public License       --
--  along with this library; if not, write to the Free Software Foundation, --
--  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.          --
--                                                                          --
--  As a special exception, if other files instantiate generics from this   --
--  unit, or you link this unit with other files to produce an executable,  --
--  this  unit  does not  by itself cause  the resulting executable to be   --
--  covered by the GNU General Public License. This exception does not      --
--  however invalidate any other reasons why the executable file  might be  --
--  covered by the  GNU Public License.                                     --
------------------------------------------------------------------------------

--  $Id$

with Interfaces.C;
with Templates_Parser;
with GNAT.Calendar.Time_IO;

with AWS.Session;
with AWS.Hotplug.Get_Status;

function AWS.Server.Get_Status (Server : in HTTP) return String is

   use Ada;
   use Templates_Parser;

   function Slot_Table return Translate_Table;
   --  returns the information for each slot

   function Session_Table return Translate_Table;
   --  returns session information

   -------------------
   -- Session_Table --
   -------------------

   function Session_Table return Translate_Table is

      Sessions : Vector_Tag;
      Keys     : Vector_Tag;
      Values   : Vector_Tag;

      procedure For_Each_Key_Value
        (N          : in     Positive;
         Key, Value : in     String;
         Quit       : in out Boolean);
      --  add key/value pair to the list

      procedure For_Each_Session
        (N          : in Positive;
         SID        : in     Session.ID;
         Time_Stamp : in     Calendar.Time;
         Quit       : in out Boolean);
      --  add session SID to the list

      ------------------------
      -- For_Each_Key_Value --
      ------------------------

      procedure For_Each_Key_Value
        (N          : in     Positive;
         Key, Value : in     String;
         Quit       : in out Boolean) is
      begin
         Keys   := Keys & ("<td>" & Key);
         Values := Values & ("<td>" & Value);
      end For_Each_Key_Value;

      --------------------------
      -- Build_Key_Value_List --
      --------------------------

      procedure Build_Key_Value_List is
         new Session.For_Every_Session_Data (For_Each_Key_Value);

      ----------------------
      -- For_Each_Session --
      ----------------------

      procedure For_Each_Session
        (N          : in Positive;
         SID        : in     Session.ID;
         Time_Stamp : in     Calendar.Time;
         Quit       : in out Boolean) is
      begin
         Sessions := Sessions & Session.Image (SID);

         Build_Key_Value_List (SID);
      end For_Each_Session;

      ------------------------
      -- Build_Session_List --
      ------------------------

      procedure Build_Session_List is
         new Session.For_Every_Session (For_Each_Session);

   begin
      Build_Session_List;

      return Translate_Table'(Assoc ("SESSIONS_L", Sessions),
                              Assoc ("KEYS_L",     Keys),
                              Assoc ("VALUES_L",   Values));
   end Session_Table;

   ----------------
   -- Slot_Table --
   ----------------

   function Slot_Table return Translate_Table is

      Sock                : Vector_Tag;
      Opened              : Vector_Tag;
      Abortable           : Vector_Tag;
      Activity_Counter    : Vector_Tag;
      Activity_Time_Stamp : Vector_Tag;

      Slot_Data           : Slot;
   begin
      for K in 1 .. Server.Max_Connection loop
         Slot_Data := Server.Slots.Get (Index => K);

         if Slot_Data.Opened then
            Sock := Sock & Integer (Sockets.Get_FD (Slot_Data.Sock));
         else
            Sock := Sock & '-';
         end if;

         Opened := Opened & Slot_Data.Opened;

         Abortable := Abortable & Slot_Data.Abortable;

         Activity_Counter := Activity_Counter & Slot_Data.Activity_Counter;

         Activity_Time_Stamp := Activity_Time_Stamp &
           GNAT.Calendar.Time_IO.Image (Slot_Data.Activity_Time_Stamp,
                                        "%a %D %T");
      end loop;

      return Translate_Table'
        (Assoc ("SOCK_L",                Sock),
         Assoc ("OPENED_L",              Opened),
         Assoc ("ABORTABLE_L",           Abortable),
         Assoc ("ACTIVITY_COUNTER_L",    Activity_Counter),
         Assoc ("ACTIVITY_TIME_STAMP_L", Activity_Time_Stamp));
   end Slot_Table;

   use type Templates_Parser.Translate_Table;

   Translations : constant Templates_Parser.Translate_Table
     := (Assoc ("SERVER_NAME",    Server.Name),
         Assoc ("MAX_CONNECTION", Server.Max_Connection),
         Assoc ("SERVER_PORT",    Server.Port),
         Assoc ("SECURITY",       Server.Security),
         Assoc ("SERVER_SOCK",    Integer (Sockets.Get_FD (Server.Sock))),
         Assoc ("VERSION",        Version),
         Assoc ("SESSION",        Server.Session),
         Assoc ("LOGO",           Server.Admin_URI & "-logo"),
         Assoc ("ADMIN",          Server.Admin_URI))
     & Slot_Table
     & Session_Table
     & Hotplug.Get_Status (Server.Filters);

begin
   return Templates_Parser.Parse ("status.tmplt", Translations);
end AWS.Server.Get_Status;
