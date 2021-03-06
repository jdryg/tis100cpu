#include "Program.h"
#include "MicroInstruction.h"

#define MIN_UNKNOWN_LABEL_ID 10000

Program::Program() : m_NextUnknownLabelID(MIN_UNKNOWN_LABEL_ID)
{

}

Program::~Program()
{
	unsigned int numInstructions = m_InstructionList.size();
	for (unsigned int i = 0; i < numInstructions; ++i)
	{
		delete m_InstructionList[i];
	}
	m_InstructionList.clear();
}

void Program::AddMicroInstruction(MicroInstruction* mi)
{
	m_InstructionList.push_back(mi);
}

void Program::AddLabel(const char* label)
{
	// NOTE: Add 1 because the label points to the next instruction.
	m_LabelMap.insert(_LabelMap::value_type(label, m_InstructionList.size()));
}

int Program::FindLabelOffset(const char* label)
{
	std::string lbl(label);

	if (m_LabelMap.count(lbl))
	{
		return m_LabelMap.at(lbl) - (m_InstructionList.size());
	}

	// Label not added yet. Check if it's in the unknown label map.
	if (m_UnknownLabels.count(lbl))
	{
		return m_UnknownLabels.at(lbl);
	}

	// Completely new label. Add it to the unknown map.
	m_UnknownLabels.insert(_LabelMap::value_type(lbl, m_NextUnknownLabelID++));

	return m_NextUnknownLabelID - 1;
}

bool Program::FixForwardJumps()
{
	// Find all jump instructions with a target greater than MIN_UNKNOWN_LABEL_ID and replace the offset with the correct value.
	unsigned int numInstructions = m_InstructionList.size();
	for (unsigned int i = 0; i < numInstructions;++i)
	{
		MicroInstruction* mi = m_InstructionList[i];
		MIMnemonic mim = mi->GetMnemonic();

		if (mim < MIM_JMP || mim > MIM_JLZ)
		{
			continue;
		}

		int jumpDelta = mi->GetImmediate();
		if (jumpDelta < MIN_UNKNOWN_LABEL_ID)
		{
			continue;
		}

		// Find the label with the same ID in the unknown label map.
		bool found = false;
		_LabelMap::iterator ulIt, ulItLast = m_UnknownLabels.end();
		for (ulIt = m_UnknownLabels.begin(); ulIt != ulItLast; ++ulIt)
		{
			if (ulIt->second == jumpDelta)
			{
				// Label found. Get the address from the label map.
				if (!m_LabelMap.count(ulIt->first))
				{
					// Label isn't included in the current program. Fail.
					break;
				}

				int offset = m_LabelMap.at(ulIt->first) - i;

				found = true;
				mi->SetImmediate(offset);
				break;
			}
		}

		if (!found)
		{
			return false;
		}
	}

	return true;
}

unsigned int* Program::GetCode() const
{
	unsigned int numInstructions = m_InstructionList.size();
	unsigned int* imem = new unsigned int[numInstructions];
	memset(imem, 0, sizeof(unsigned int) * numInstructions);

	for (unsigned int i = 0; i < numInstructions; ++i)
	{
		MicroInstruction* mi = m_InstructionList[i];

		unsigned int containsIMM = mi->GetSourceB() == MIS_IMM ? 1 : 0;
		unsigned int imm = mi->GetImmediate();

		unsigned int dst = 0;
		bool dst_IsPort = false;
		switch (mi->GetDestination())
		{
		case MID_NIL:        dst = 0; break;
		case MID_ACC:        dst = 1; break;
		case MID_BAK:        dst = 2; break;
		case MID_TMP:        dst = 3; break;
		case MID_PORT_UP:    dst = 0; dst_IsPort = true; break;
		case MID_PORT_DOWN:  dst = 1; dst_IsPort = true; break;
		case MID_PORT_LEFT:  dst = 2; dst_IsPort = true; break;
		case MID_PORT_RIGHT: dst = 3; dst_IsPort = true; break;
		}

		unsigned int srcA = 0;
		bool srcA_isPort = false;
		switch (mi->GetSourceA())
		{
		case MIS_NIL:        srcA = 0; break;
		case MIS_ACC:        srcA = 1; break;
		case MIS_BAK:        srcA = 2; break;
		case MIS_TMP:        srcA = 3; break;
		case MIS_PORT_UP:    srcA = 0; srcA_isPort = true; break;
		case MIS_PORT_DOWN:  srcA = 1; srcA_isPort = true; break;
		case MIS_PORT_LEFT:  srcA = 2; srcA_isPort = true; break;
		case MIS_PORT_RIGHT: srcA = 3; srcA_isPort = true; break;
		}

		unsigned int srcB = 0;
		switch (mi->GetSourceB())
		{
		case MIS_NIL:        srcB = 0; break;
		case MIS_IMM:        srcB = 0; break;
		case MIS_ACC:        srcB = 1; break;
		case MIS_BAK:        srcB = 2; break;
		case MIS_TMP:        srcB = 3; break;
		case MIS_PORT_UP:    srcB = 0; break;
		case MIS_PORT_DOWN:  srcB = 1; break;
		case MIS_PORT_LEFT:  srcB = 2; break;
		case MIS_PORT_RIGHT: srcB = 3; break;
		}

		bool invalidInstruction = false;
		unsigned int instructionType = 0;
		unsigned int operation = 0;
		switch (mi->GetMnemonic())
		{
		case MIM_ADD:
			if (!dst_IsPort && !srcA_isPort)
			{
				instructionType = 0;
				operation = 0;
			}
			else
			{
				instructionType = 1;
				if (!dst_IsPort && srcA_isPort)
				{
					operation = 0; // ADD reg, port, reg/imm <= RDP
				}
				else if (dst_IsPort && !srcA_isPort)
				{
					operation = 1; // ADD port, reg, reg/imm <= WRP
				}
				else
				{
					operation = 2; // ADD port, port, reg/imm
				}
			}
			break;
		case MIM_SUB:
			if (!dst_IsPort && !srcA_isPort)
			{
				instructionType = 0;
				operation = 1;
			}
			else
			{
				instructionType = 1;
				if (!dst_IsPort && srcA_isPort)
				{
					// SUB reg, port, reg/imm
					invalidInstruction = true;
				}
				else if (dst_IsPort && !srcA_isPort)
				{
					// SUB port, reg, reg/imm
					invalidInstruction = true;
				}
				else
				{
					// SUB port, port, reg/imm
					invalidInstruction = true;
				}
			}
			break;
		case MIM_NEG:
			if (!dst_IsPort && !srcA_isPort)
			{
				instructionType = 0;
				operation = 2;
			}
			else
			{
				invalidInstruction = true;
			}
			break;
		case MIM_ISUB:
			if (!dst_IsPort && !srcA_isPort)
			{
				instructionType = 0;
				operation = 4;
			}
			else
			{
				instructionType = 1;
				if (!dst_IsPort && srcA_isPort)
				{
					operation = 3; // ISUB reg, port, reg/imm
				}
				else if (dst_IsPort && !srcA_isPort)
				{
					// ISUB port, reg, reg/imm
					invalidInstruction = true;
				}
				else
				{
					// ISUB port, port, reg/imm
					invalidInstruction = true;
				}
			}
			break;
		case MIM_SWP:
			instructionType = 0;
			operation = 4; // 100
			break;
		case MIM_RDP:
			// TODO: Remove this
			instructionType = 1;
			operation = 0;
			break;
		case MIM_WRP:
			// TODO: Remove this
			instructionType = 1;
			operation = 1;
			break;
		case MIM_JMP:
		case MIM_JRO:
			instructionType = 2;
			operation = 0;
			break;
		case MIM_JEZ:
			instructionType = 2;
			operation = 3;
			break;
		case MIM_JNZ:
			instructionType = 2;
			operation = 4;
			break;
		case MIM_JGZ:
			instructionType = 2;
			operation = 1;
			break;
		case MIM_JLZ:
			instructionType = 2;
			operation = 2;
			break;
		}

		if (invalidInstruction)
		{
			delete[] imem;
			return 0;
		}

		unsigned int opcode = 0;
		opcode |= (containsIMM & 0x00000001) << 31;
		opcode |= (instructionType & 0x00000003) << 29;
		opcode |= (operation & 0x00000007) << 26;
		opcode |= (dst & 0x00000007) << 23;
		opcode |= (srcA & 0x00000007) << 20;
		opcode |= (srcB & 0x00000003) << 18;
		opcode |= imm & 0x0000FFFF;

		imem[i] = opcode;
	}

	// Raise the 'reset PC' flag on the last instruction.
	imem[numInstructions - 1] |= 1 << 16;

	return imem;
}