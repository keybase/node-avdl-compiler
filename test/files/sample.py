"""sample.1

Auto-generated to Python types by avdl-compiler v1.4.1 (https://github.com/keybase/node-avdl-compiler)
Input files:
 - avdl/sample.avdl
"""

from ithub.com.keybase/client/go/protocol/keybase1 import * as keybase1

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
    AGGLE: Optional[int[]]
@dataclass
class BoozleFLAGGLE:
    typ: Types.FLAGGLE
    FLAGGLE: Optional[boolean[]]
Boozle = Union[BoozleBOZO, BoozleBIPPY, BoozleAGGLE, BoozleFLAGGLE]

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

@dataclass
class Simple(DataClassJSONMixin):
    s: Optional[*Blurp]



Hash = bytes
@dataclass
class Cat(DataClassJSONMixin):
    bird: Dict[str, Noozle]
    bee: Dict[str, Noozle]
    birds: Dict[str, []Noozle]
    pickles: Dict[str, int]
    penny: Dict[str, int]
    pa: Dict[str, str]
    wow: []Dict[str, []Noozle]
    boo: bytes
    hooHah: Hash
    seqno: rpc.SeqNumber



messageID = uint
BigBytes = Optional[str]
