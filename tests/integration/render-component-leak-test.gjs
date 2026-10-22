import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-render-component-leak/tests/helpers';
import { render, settled, setupOnerror } from '@ember/test-helpers';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

class State {
  @tracked value = 0;
}

class Boom extends Component {
  constructor() {
    super(...arguments);
    throw new Error('boom');
  }
}

module('Integration | renderComponent leak', function (hooks) {
  setupRenderingTest(hooks);

  test('a component that throws on its first render', async function (assert) {
    setupOnerror((error) => {
      assert.strictEqual(error.message, 'boom');
    });

    await render(<template><Boom /></template>);
  });

  test('the next test', async function (assert) {
    const state = new State();
    const warnings = [];
    const { warn } = console;

    console.warn = (message) => warnings.push(message);

    try {
      await render(<template>{{state.value}}</template>);

      state.value = 1;

      await settled();
    } finally {
      console.warn = warn;
    }

    assert.dom().hasText('1');
    assert.deepEqual(warnings, [], 'the previous test left nothing behind');
  });
});
