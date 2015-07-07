#include "TIS100Instruction.h"
#include "GenericParser.h"
#include <malloc.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

TIS100Instruction::TIS100Instruction() : m_Label(0), m_JumpTarget(0), m_Dest(TISD_Unknown), m_Src(TISS_Unknown), m_Immediate(0), m_Mnemonic(TISM_Unknown)
{
}

TIS100Instruction::~TIS100Instruction()
{
	if (m_Label)
	{
		free(m_Label);
	}

	if (m_JumpTarget)
	{
		free(m_JumpTarget);
	}
}

void TIS100Instruction::SetLabel(const char* label)
{
	m_Label = _strdup(label);
}

void TIS100Instruction::SetJumpTarget(const char* target)
{
	m_JumpTarget = _strdup(target);
}

bool TIS100Instruction::SetDestination(const char* str)
{
	m_Dest = TIS100Instruction::StringToDestination(str);

	return m_Dest != TISD_Unknown;
}

bool TIS100Instruction::SetSource(const char* str)
{
	// Check if this is an integer constant.
	if (GenericParser::IsNumber(str[0]))
	{
		int imm = atoi(str);

		char tmpStr[64];
		sprintf_s(tmpStr, 64, "%d", imm);

		if (strcmp(str, tmpStr))
		{
			return false;
		}

		m_Src = TISS_IMM;
		m_Immediate = imm;
	}
	else
	{
		m_Src = TIS100Instruction::StringToSource(str);
	}

	return m_Src != TISS_Unknown;
}

TIS100Destination TIS100Instruction::StringToDestination(const char* str)
{
	if (!_stricmp(str, "acc"))        { return TISD_ACC;        }
	else if (!_stricmp(str, "nil"))   { return TISD_NIL;        }
	else if (!_stricmp(str, "up"))    { return TISD_PORT_UP;    }
	else if (!_stricmp(str, "down"))  { return TISD_PORT_DOWN;  }
	else if (!_stricmp(str, "left"))  { return TISD_PORT_LEFT;  }
	else if (!_stricmp(str, "right")) { return TISD_PORT_RIGHT; }
	else if (!_stricmp(str, "any"))   { return TISD_PORT_ANY;   }
	else if (!_stricmp(str, "last"))  { return TISD_PORT_LAST;  }

	return TISD_Unknown;
}

TIS100Source TIS100Instruction::StringToSource(const char* str)
{
	if (!_stricmp(str, "acc"))        { return TISS_ACC; }
	else if (!_stricmp(str, "nil"))   { return TISS_NIL; }
	else if (!_stricmp(str, "up"))    { return TISS_PORT_UP; }
	else if (!_stricmp(str, "down"))  { return TISS_PORT_DOWN; }
	else if (!_stricmp(str, "left"))  { return TISS_PORT_LEFT; }
	else if (!_stricmp(str, "right")) { return TISS_PORT_RIGHT; }
	else if (!_stricmp(str, "any"))   { return TISS_PORT_ANY; }
	else if (!_stricmp(str, "last"))  { return TISS_PORT_LAST; }

	return TISS_Unknown;
}
