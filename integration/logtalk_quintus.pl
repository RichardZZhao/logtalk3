%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  This file is part of Logtalk <http://logtalk.org/>  
%  Copyright (c) 1998-2014 Paulo Moura <pmoura@logtalk.org>
%
%  Integration file for Quintus Prolog
%  Last updated on October 11, 2013
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%  
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%  
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.
%  
%  Additional licensing terms apply per Section 7 of the GNU General
%  Public License 3. Consult the `LICENSE.txt` file for details.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- 	unix(args([LOGTALKHOME| _])),	% hack for workaround the lack of support for environment variables in file names
	atom_chars(LOGTALKHOME, LH0),
	quintus_reverse_slashes(LH0, LH),
	atom_chars('/adapters/quintus.pl', LC), append(LH, LC, L1), atom_chars(AdapterFile, L1), compile(AdapterFile),
	atom_chars('/paths/paths.pl', LP), append(LH, LP, L3), atom_chars(PathsFile, L3), compile(PathsFile),
	atom_chars('/core/core.pl', LL), append(LH, LL, L2), atom_chars(CompilerFile, L2), compile(CompilerFile).

quintus_reverse_slashes([], []).
quintus_reverse_slashes([Char| Chars], [ConvertedChar| ConvertedChars]) :-
	(	Char =:= 0'\ ->
		ConvertedChar = 0'/
	;	ConvertedChar = Char
	),
	quintus_reverse_slashes(Chars, ConvertedChars).
