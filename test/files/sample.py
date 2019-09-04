"""sample.1

Auto-generated to Python types by avdl-compiler v1.4.1 (https://github.com/keybase/node-avdl-compiler)
Input files:
 - avdl/sample.avdl
"""

from dataclasses import dataclass
from enum import Enum
from typing import Dict, List, Optional, Union

from mashumaro import DataClassJSONMixin

import keybase1

Joe = int
@dataclass
class R(DataClassJSONMixin):
    bar: keybase1.UID
    bazJUid: keybase1.UID
    woop: Optional[str]


class Types(Enum):
    NONE = 'none'
    BOZO = 'bozo'
    BIPPY = 'bippy'
    AGGLE = 'aggle'
    FLAGGLE = 'flaggle'


class EnumNoString(Enum):
    NOSTRING = 'nostring'


@dataclass
class BoozleBOZO:
    typ: Types.BOZO
    BOZO: Optional[int]
@dataclass
class BoozleBIPPY:
    typ: Types.BIPPY
    BIPPY: Optional[str]
@dataclass
class BoozleAGGLE:
    typ: Types.AGGLE
    AGGLE: Optional[List[int]]
@dataclass
class BoozleFLAGGLE:
    typ: Types.FLAGGLE
    FLAGGLE: Optional[List[bool]]
Boozle = Union[BoozleBOZO, BoozleBIPPY, BoozleAGGLE, BoozleFLAGGLE]

@dataclass
class Noozle1:
    version: int.1
    1: Optional[str]
@dataclass
class Noozle2:
    version: int.2
    2: Optional[int]
Noozle = Union[Noozle1, Noozle2]

@dataclass
class Blurptrue:
    b: boolean.true
    true: Optional[str]
@dataclass
class Blurpfalse:
    b: boolean.false
    false: Optional[int]
Blurp = Union[Blurptrue, Blurpfalse]

Hash = bytes
messageID = int
BigBytes = Optional[str]
class TeamInviteCategory(Enum):
    NONE = 'none'
    UNKNOWN = 'unknown'
    KEYBASE = 'keybase'
    EMAIL = 'email'
    SBS = 'sbs'
    SEITAN = 'seitan'
    PHONE = 'phone'


@dataclass
class TeamInviteTypeUNKNOWN:
    c: TeamInviteCategory.UNKNOWN
    UNKNOWN: Optional[str]
@dataclass
class TeamInviteTypeSBS:
    c: TeamInviteCategory.SBS
    SBS: Optional[int]
TeamInviteType = Union[TeamInviteTypeUNKNOWN, TeamInviteTypeSBS]

@dataclass
class TrixieNONE:
    typ: Types.NONE
    NONE: Optional[null]
@dataclass
class TrixieBOZO:
    typ: Types.BOZO
    BOZO: Optional[null]
@dataclass
class TrixieBIPPY:
    typ: Types.BIPPY
    BIPPY: Optional[int]
@dataclass
class TrixieAGGLE:
    typ: Types.AGGLE
    AGGLE: Optional[null]
@dataclass
class TrixieFLAGGLE:
    typ: Types.FLAGGLE
    FLAGGLE: Optional[EnumNoString]
Trixie = Union[TrixieNONE, TrixieBOZO, TrixieBIPPY, TrixieAGGLE, TrixieFLAGGLE]

@dataclass
class Simple(DataClassJSONMixin):
    s: Optional[Blurp]


@dataclass
class Cat(DataClassJSONMixin):
    bird: Dict[str, Noozle]
    bee: Dict[str, Noozle]
    birds: Dict[str, List[Noozle]]
    pickles: Dict[str, int]
    penny: Dict[str, int]
    pa: Dict[str, str]
    wow: List[Dict[str, List[Noozle]]]
    boo: bytes
    hooHah: Hash
    seqno: rpc.SeqNumber
