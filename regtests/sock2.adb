------------------------------------------------------------------------------
--                              Ada Web Server                              --
--                                                                          --
--                         Copyright (C) 2000-2001                          --
--                               ACT-Europe                                 --
--                                                                          --
--  Authors: Dmitriy Anisimkov - Pascal Obry                                --
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

--  Test for bid data send/receive.

with AWS.Net;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Streams;

procedure Sock2 is
   use AWS;
   use Ada;
   use Ada.Streams;

   Port : constant := 8800;

   Sample : Stream_Element_Array (1 .. 100_000);

   Server, Peer, Client : Net.Socket_Type'Class := Net.Socket (False);

   task Client_Side is
      entry Start;
      entry Stop;
   end Client_Side;

   -----------------
   -- Client_Side --
   -----------------

   task body Client_Side is
      First  : Stream_Element_Offset := Sample'First;
   begin
      accept Start;

      Net.Connect (Client, "localhost", Port);

      loop
         declare
            Buffer : Stream_Element_Array := Net.Receive (Client);
            Next   : Stream_Element_Offset := First + Buffer'Length;
         begin
            if Buffer'Length = 0 then
               Text_IO.Put_Line ("short data");
            elsif Sample (First .. Next - 1) /= Buffer then
               Text_IO.Put_Line ("wrong data");
            end if;

            exit when Next > Sample'Last;

            First := Next;
         end;
      end loop;

      Net.Shutdown (Client);

      Text_IO.Put_Line ("client task done.");

      accept Stop;
   exception
      when E : others =>
         Text_IO.Put_Line (Exceptions.Exception_Information (E));

         accept Stop;
   end Client_Side;

begin
   for J in Sample'Range loop
      Sample (J) := Stream_Element
                      (J mod Stream_Element_Offset (Stream_Element'Last));
   end loop;

   Text_IO.Put_Line ("start");

   Net.Bind (Server, Port);
   Net.Listen (Server);

   Client_Side.Start;

   Net.Accept_Socket (Server, Peer);

   Net.Send (Peer, Sample);

   Client_Side.Stop;

   Net.Shutdown (Peer);

   Text_IO.Put_Line ("done.");
end Sock2;