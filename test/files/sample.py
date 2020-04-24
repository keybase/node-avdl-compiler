"""sample.1

Auto-generated to Python types by avdl-compiler v1.4.9 (https://github.com/keybase/node-avdl-compiler)
Input files:
 - avdl/sample.avdl
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import Dict, List, Optional, Union
from typing_extensions import Literal

from dataclasses_json import config, DataClassJsonMixin

import github.com.keybase.client.go.protocol.keybase1 as keybase1

Joe = int
@dataclass
class R(DataClassJsonMixin):
    bar: keybase1.UID = field(metadata=config(field_name='bar'))
    baz: keybase1.UID = field(metadata=config(field_name='baz_j_uid'))
    woop: Optional[str] = field(default=None, metadata=config(field_name='woop'))

class Types(Enum):
    NONE = 0
    BOZO = 1
    BIPPY = 2
    AGGLE = 3
    FLAGGLE = 4

class TypesStrings(Enum):
    NONE = 'none'
    BOZO = 'bozo'
    BIPPY = 'bippy'
    AGGLE = 'aggle'
    FLAGGLE = 'flaggle'


class EnumNoString(Enum):
    NOSTRING = 0

class EnumNoStringStrings(Enum):
    NOSTRING = 'nostring'


@dataclass
class Boozle__BOZO(DataClassJsonMixin):
    typ: Literal[TypesStrings.BOZO]
    BOZO: Optional[int]

@dataclass
class Boozle__BIPPY(DataClassJsonMixin):
    typ: Literal[TypesStrings.BIPPY]
    BIPPY: Optional[str]

@dataclass
class Boozle__AGGLE(DataClassJsonMixin):
    typ: Literal[TypesStrings.AGGLE]
    AGGLE: Optional[List[int]]

@dataclass
class Boozle__FLAGGLE(DataClassJsonMixin):
    typ: Literal[TypesStrings.FLAGGLE]
    FLAGGLE: Optional[List[bool]]

Boozle = Union[Boozle__BOZO, Boozle__BIPPY, Boozle__AGGLE, Boozle__FLAGGLE]

@dataclass
class Trixie__NONE(DataClassJsonMixin):
    typ: Literal[TypesStrings.NONE]
    NONE: None

@dataclass
class Trixie__BOZO(DataClassJsonMixin):
    typ: Literal[TypesStrings.BOZO]
    BOZO: None

@dataclass
class Trixie__BIPPY(DataClassJsonMixin):
    typ: Literal[TypesStrings.BIPPY]
    BIPPY: Optional[int]

@dataclass
class Trixie__AGGLE(DataClassJsonMixin):
    typ: Literal[TypesStrings.AGGLE]
    AGGLE: None

@dataclass
class Trixie__FLAGGLE(DataClassJsonMixin):
    typ: Literal[TypesStrings.FLAGGLE]
    FLAGGLE: Optional[EnumNoString]

Trixie = Union[Trixie__NONE, Trixie__BOZO, Trixie__BIPPY, Trixie__AGGLE, Trixie__FLAGGLE]

@dataclass
class Noozle__1(DataClassJsonMixin):
    version: Literal[1]
    1: Optional[str]

@dataclass
class Noozle__2(DataClassJsonMixin):
    version: Literal[2]
    2: Optional[int]

Noozle = Union[Noozle__1, Noozle__2]

@dataclass
class Blurp__true(DataClassJsonMixin):
    b: Literal[true]
    true: Optional[str]

@dataclass
class Blurp__false(DataClassJsonMixin):
    b: Literal[false]
    false: Optional[int]

Blurp = Union[Blurp__true, Blurp__false]

@dataclass
class Simple(DataClassJsonMixin):
    s: Optional[Blurp] = field(default=None, metadata=config(field_name='s'))
    t: Optional[Blurp] = field(default=None, metadata=config(field_name='t'))
    u: Optional[List[Blurp]] = field(default=None, metadata=config(field_name='u'))

Hash = str
@dataclass
class Cat(DataClassJsonMixin):
    bird: Dict[str, Noozle] = field(metadata=config(field_name='bird'))
    bee: Dict[str, Noozle] = field(metadata=config(field_name='bee'))
    birds: Dict[str, Optional[List[Noozle]]] = field(metadata=config(field_name='birds'))
    pickles: Dict[str, int] = field(metadata=config(field_name='pickles'))
    penny: Dict[str, int] = field(metadata=config(field_name='penny'))
    pa: Dict[str, str] = field(metadata=config(field_name='pa'))
    boo: str = field(metadata=config(field_name='boo'))
    hoo_hah: Hash = field(metadata=config(field_name='hooHah'))
    seqno: rpc.SeqNumber = field(metadata=config(field_name='seqno'))
    wow: Optional[List[Dict[str, Optional[List[Noozle]]]]] = field(default=None, metadata=config(field_name='wow'))

messageID = int
BigBytes = Optional[str]
class TeamInviteCategory(Enum):
    NONE = 0
    UNKNOWN = 1
    KEYBASE = 2
    EMAIL = 3
    SBS = 4
    SEITAN = 5
    PHONE = 6

class TeamInviteCategoryStrings(Enum):
    NONE = 'none'
    UNKNOWN = 'unknown'
    KEYBASE = 'keybase'
    EMAIL = 'email'
    SBS = 'sbs'
    SEITAN = 'seitan'
    PHONE = 'phone'


@dataclass
class TeamInviteType__UNKNOWN(DataClassJsonMixin):
    c: Literal[TeamInviteCategoryStrings.UNKNOWN]
    UNKNOWN: Optional[str]

@dataclass
class TeamInviteType__SBS(DataClassJsonMixin):
    c: Literal[TeamInviteCategoryStrings.SBS]
    SBS: Optional[int]

TeamInviteType = Union[TeamInviteType__UNKNOWN, TeamInviteType__SBS]
