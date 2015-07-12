#include <cstdlib>
#include <string.h>
#include "GenericParser.h"

#pragma warning(disable: 4127) // conditional expression is constant

bool GenericParser::IsWhiteSpace(char character)
{
	if(character == ' ' || character == '\t' || character == '\n' || character == '\r' || character == 0)
		return true;

	return false;
}

bool GenericParser::IsNumber(char c)
{
	if(c >= '0' && c <= '9')
		return true;

	return false;
}

bool GenericParser::IsAlphaUnderscore(char c)
{
	if(c >= 'a' && c <= 'z')
		return true;
	if(c >= 'A' && c <= 'Z')
		return true;
	if(c == '_')
		return true;

	return false;
}

bool GenericParser::GetNextToken(char* string, unsigned int size)
{
	if(m_String[m_CurPos] == '\0')
		return false;

	SkipComments();

	unsigned int NumCharacters = 0;
	while((IsNumber(m_String[m_CurPos]) || IsAlphaUnderscore(m_String[m_CurPos])) && NumCharacters < size)
		string[NumCharacters++] = m_String[m_CurPos++];

	//////////////////////////////////////////////////////////////////////////
	// If NumCharacters is zero, this means that the string is empty. This means
	// that at the current point the buffer passed contains no alphanumeric value
	// and may contain a symbol of type {, }, (, ) , ....
	// So check if it's not at the end of the string and return the first byte.
	// 
	if(NumCharacters == 0 && m_String[m_CurPos] != '\0')
		string[NumCharacters++] = m_String[m_CurPos++];

	SkipComments();

	string[NumCharacters] = '\0';

	return true;
}

bool GenericParser::GetString(char* string, int size)
{
	if(m_String[m_CurPos] == '\0')
		return false;

	SkipComments();

	if(m_String[m_CurPos] != '\"')
		return false;

	++m_CurPos;

	int NumCharacters = 0;
	while(m_String[m_CurPos] != '\"' && NumCharacters < size)
	{
		if(m_String[m_CurPos] == '\n')
		{
			++m_CurPos;
			string[NumCharacters++] = '\0';
			return false;
		}

		string[NumCharacters++] = m_String[m_CurPos++];
	}

	string[NumCharacters++] = '\0';

	// Skip closing quote
	++m_CurPos;

	SkipComments();

	return true;
}

bool GenericParser::GetFloat(float& value)
{
	if(m_String[m_CurPos] == '\0')
		return false;

	SkipComments();

	char StrValue[64];
	int NumChars = 0;

	bool PeriodFound = false;
	while(!IsWhiteSpace(m_String[m_CurPos]))
	{
		if(!IsNumber(m_String[m_CurPos]))
		{
			if(m_String[m_CurPos] == 'e')
			{
				StrValue[NumChars++] = m_String[m_CurPos++];
				PeriodFound = true;
			}
			else if(m_String[m_CurPos] == '-' || m_String[m_CurPos] == '+')
				StrValue[NumChars++] = m_String[m_CurPos++];
			else
			{
				if(PeriodFound)
				{
					if(m_String[m_CurPos] == 'f')
						++m_CurPos;
					break;
				}
				else
				{
					if(m_String[m_CurPos] == '.')
					{
						StrValue[NumChars++] = m_String[m_CurPos++];
						PeriodFound = true;
					}
					else
						break;
				}
			}
		}
		else
			StrValue[NumChars++] = m_String[m_CurPos++];
	}
	StrValue[NumChars] = '\0';

	value = (float)atof(StrValue);

	SkipComments();

	return true;
}

bool GenericParser::GetInteger(int& value)
{
	if(m_String[m_CurPos] == '\0')
		return false;

	SkipComments();

	char strValue[16];
	int numChars = 0;

	if(m_String[m_CurPos] == '-' || m_String[m_CurPos] == '+')
		strValue[numChars++] = m_String[m_CurPos++];

	while(IsNumber(m_String[m_CurPos]))
		strValue[numChars++] = m_String[m_CurPos++];
	strValue[numChars] = '\0';

	value = atoi(strValue);

	SkipComments();

	return true;
}

bool GenericParser::Expecting(char character)
{
	if(m_String[m_CurPos] == '\0')
		return false;

	SkipComments();

	if(m_String[m_CurPos] != character)
		return false;

	++m_CurPos;

	SkipComments();

	return true;
}

void GenericParser::SkipWhiteSpaces(void)
{
	while(m_String[m_CurPos] == ' ' || m_String[m_CurPos] == '\n' || m_String[m_CurPos] == '\t' || m_String[m_CurPos] == '\r')
		++m_CurPos;
}

void GenericParser::SkipComments(void)
{
	SkipWhiteSpaces();

	do 
	{
		if(m_String[m_CurPos] == '#')
		{
			// Single-line comment
			while (m_String[m_CurPos] != '\n' && m_String[m_CurPos] != '\r' && m_String[m_CurPos] != '\0')
			{
				++m_CurPos;
			}
		}
		else
		{
			break;
		}

		SkipWhiteSpaces();
	} while(true);
}

bool GenericParser::GetIdentifier(char* ident, unsigned int maxSize)
{
	if(m_String[m_CurPos] == '\0')
		return false;

	SkipComments();

	if(IsNumber(m_String[m_CurPos]) || !IsAlphaUnderscore(m_String[m_CurPos]))
		return false;

	unsigned int numChars = 0;
	ident[numChars++] = m_String[m_CurPos++];

	while((IsNumber(m_String[m_CurPos]) || IsAlphaUnderscore(m_String[m_CurPos])) && numChars < maxSize)
		ident[numChars++] = m_String[m_CurPos++];
	ident[numChars] = '\0';

	SkipComments();

	return true;
}

bool GenericParser::GetBoolean(bool& value)
{
	if(m_String[m_CurPos] == '\0')
		return false;

	char boolValueStr[32];
	if(!GetIdentifier(boolValueStr, 32))
		return false;

	if(!_stricmp(boolValueStr, "true"))
	{
		value = true;
		return true;
	}
	else if(!_stricmp(boolValueStr, "false"))
	{
		value = false;
		return true;
	}

	return false;
}

#pragma warning(default: 4127) // conditional expression is constant
