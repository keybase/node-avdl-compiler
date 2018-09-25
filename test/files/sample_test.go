package sample1

import (
	"testing"

	"github.com/keybase/client/go/protocol/keybase1"
	"github.com/stretchr/testify/require"
	"golang.org/x/net/context"
)

type fakeSample struct{}

func (fakeSample) GetBaz(ctx context.Context, arg GetBazArg) (keybase1.SigID, error) {
	return keybase1.SigID(""), nil
}

func (fakeSample) Notifier(ctx context.Context, n int) error {
	return nil
}

func TestCall(t *testing.T) {
	protocol := SampleProtocol(fakeSample{})
	getBazDesc := protocol.Methods["getBaz"]
	args := getBazDesc.MakeArg()
	_, err := getBazDesc.Handler(context.Background(), args)
	require.NoError(t, err)
}
